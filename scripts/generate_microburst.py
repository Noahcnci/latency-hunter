#!/usr/bin/env python3
"""
Network Microburst Generator
Generates controlled network microbursts using iperf3 for latency testing.

Author: Latency Hunter Project
Version: 1.0
"""

import argparse
import subprocess
import time
import sys
import json
from datetime import datetime
from typing import Optional, Dict


class MicroBurstGenerator:
    """Network microburst generator using iperf3"""
    
    def __init__(self, target_host="10.0.1.12", target_port=5201, verbose=True):
        """
        Initialize burst generator
        
        Args:
            target_host: Target iperf3 server IP address
            target_port: Target iperf3 server port
            verbose: Enable detailed output
        """
        self.target_host = target_host
        self.target_port = target_port
        self.verbose = verbose
        self.results = []
    
    def verify_server(self) -> bool:
        """
        Verify iperf3 server is accessible
        
        Returns:
            bool: True if server is accessible, False otherwise
        """
        try:
            result = subprocess.run(
                ['docker', 'exec', 'clab-latency-hunter-traffic-gen-2', 
                 'pgrep', '-x', 'iperf3'],
                capture_output=True,
                text=True,
                timeout=5
            )
            return result.returncode == 0
        except Exception as e:
            if self.verbose:
                print(f"[ERROR] Server verification failed: {e}")
            return False
    
    def generate_burst(
        self,
        duration_ms: int = 200,
        bandwidth: str = "8G",
        protocol: str = "udp",
        parallel: int = 4,
        packet_size: int = 1400
    ) -> Optional[Dict]:
        """
        Generate a single network microburst
        
        Args:
            duration_ms: Burst duration in milliseconds
            bandwidth: Target bandwidth (e.g., "8G", "10G", "500M")
            protocol: Transport protocol ("udp" or "tcp")
            parallel: Number of parallel streams
            packet_size: Packet size in bytes
            
        Returns:
            Dict containing burst results or None on failure
        """
        duration_sec = duration_ms / 1000.0
        
        # Build iperf3 command
        cmd = [
            'docker', 'exec', 'clab-latency-hunter-traffic-gen-1',
            'iperf3', '-c', self.target_host,
            '-p', str(self.target_port),
            '-b', bandwidth,
            '-t', str(duration_sec),
            '-P', str(parallel),
            '-l', str(packet_size),
            '--json'
        ]
        
        if protocol.lower() == "udp":
            cmd.append('-u')
        
        if self.verbose:
            print("\n" + "="*70)
            print("BURST CONFIGURATION")
            print("="*70)
            print(f"Target          : {self.target_host}:{self.target_port}")
            print(f"Duration        : {duration_ms} ms")
            print(f"Bandwidth       : {bandwidth}")
            print(f"Protocol        : {protocol.upper()}")
            print(f"Parallel Streams: {parallel}")
            print(f"Packet Size     : {packet_size} bytes")
            print(f"Timestamp       : {datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
            print("="*70)
            print("[STATUS] Initiating burst...")
        
        try:
            start_time = time.time()
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=1  # 1 second safety timeout
            )
            end_time = time.time()
            actual_duration = (end_time - start_time) * 1000
            
            if result.returncode == 0:
                try:
                    data = json.loads(result.stdout)
                    sent_bytes = data.get('end', {}).get('sum_sent', {}).get('bytes', 0)
                    sent_mbps = (sent_bytes * 8) / (actual_duration / 1000) / 1_000_000
                    
                    if self.verbose:
                        print("[STATUS] Burst completed successfully")
                        print("="*70)
                        print("BURST RESULTS")
                        print("="*70)
                        print(f"Actual Duration : {actual_duration:.2f} ms")
                        print(f"Data Sent       : {sent_bytes / 1_000_000:.2f} MB")
                        print(f"Avg. Throughput : {sent_mbps:.2f} Mbps")
                        print("="*70 + "\n")
                    
                    return {
                        "duration_ms": actual_duration,
                        "bytes": sent_bytes,
                        "mbps": sent_mbps,
                        "status": "success"
                    }
                except json.JSONDecodeError:
                    if self.verbose:
                        print("[WARNING] Unable to parse JSON output")
                        print(f"Raw output: {result.stdout[:200]}")
                    return {
                        "duration_ms": actual_duration,
                        "status": "success_no_json"
                    }
            else:
                if self.verbose:
                    print(f"[ERROR] iperf3 failed with return code {result.returncode}")
                    print(f"Error output: {result.stderr}")
                return None
                
        except subprocess.TimeoutExpired:
            end_time = time.time()
            actual_duration = (end_time - start_time) * 1000
            if self.verbose:
                print("[STATUS] Burst completed (forced timeout)")
                print("="*70)
                print("BURST RESULTS")
                print("="*70)
                print(f"Actual Duration : {actual_duration:.2f} ms")
                print(f"Note            : Timeout forced termination (normal for bursts < 1s)")
                print(f"Traffic sent for: ~{actual_duration:.0f} ms")
                print("="*70 + "\n")
            return {
                "duration_ms": actual_duration,
                "status": "timeout_ok"
            }
                
        except Exception as e:
            print(f"[ERROR] Unexpected error: {e}")
            return None
    
    def generate_pattern(
        self,
        num_bursts: int = 5,
        interval_sec: int = 10,
        **burst_params
    ) -> list:
        """
        Generate a pattern of multiple bursts
        
        Args:
            num_bursts: Number of bursts to generate
            interval_sec: Seconds between bursts
            **burst_params: Parameters to pass to generate_burst()
            
        Returns:
            List of burst results
        """
        print("\n" + "="*70)
        print("BURST PATTERN EXECUTION")
        print("="*70)
        print(f"Total Bursts    : {num_bursts}")
        print(f"Interval        : {interval_sec} seconds")
        print("="*70 + "\n")
        
        results = []
        for i in range(num_bursts):
            print(f"[INFO] Executing burst {i+1}/{num_bursts}")
            result = self.generate_burst(**burst_params)
            if result:
                results.append(result)
            
            if i < num_bursts - 1:
                print(f"[INFO] Waiting {interval_sec} seconds until next burst...")
                time.sleep(interval_sec)
        
        # Summary
        print("\n" + "="*70)
        print("PATTERN SUMMARY")
        print("="*70)
        print(f"Bursts Executed : {len(results)}/{num_bursts}")
        if results:
            avg_duration = sum(r['duration_ms'] for r in results) / len(results)
            print(f"Avg Duration    : {avg_duration:.2f} ms")
        print("="*70 + "\n")
        
        return results


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Network Microburst Generator',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  Generate 200ms burst at 8 Gbps:
    python3 generate_microburst.py --duration 200 --rate 8G

  Generate 5 bursts with 10 second intervals:
    python3 generate_microburst.py --duration 200 --rate 8G --pattern 5 --interval 10

  Generate TCP burst:
    python3 generate_microburst.py --duration 500 --rate 10G --protocol tcp
        '''
    )
    
    parser.add_argument(
        '--duration',
        type=int,
        default=200,
        help='Burst duration in milliseconds (default: 200)'
    )
    parser.add_argument(
        '--rate',
        type=str,
        default='8G',
        help='Target bandwidth (e.g., 8G, 10G, 500M) (default: 8G)'
    )
    parser.add_argument(
        '--protocol',
        type=str,
        choices=['udp', 'tcp'],
        default='udp',
        help='Transport protocol (default: udp)'
    )
    parser.add_argument(
        '--parallel',
        type=int,
        default=4,
        help='Number of parallel streams (default: 4)'
    )
    parser.add_argument(
        '--packet-size',
        type=int,
        default=1400,
        help='Packet size in bytes (default: 1400)'
    )
    parser.add_argument(
        '--pattern',
        type=int,
        help='Generate pattern of N bursts'
    )
    parser.add_argument(
        '--interval',
        type=int,
        default=10,
        help='Seconds between bursts in pattern mode (default: 10)'
    )
    parser.add_argument(
        '--quiet',
        action='store_true',
        help='Suppress detailed output'
    )
    
    args = parser.parse_args()
    
    # Initialize generator
    generator = MicroBurstGenerator(verbose=not args.quiet)
    
    # Verify server
    print("[INFO] Verifying iperf3 server availability...")
    if not generator.verify_server():
        print("[ERROR] iperf3 server not accessible")
        print("[INFO] Start server with: docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s")
        sys.exit(1)
    print("[OK] iperf3 server is accessible\n")
    
    # Generate burst(s)
    burst_params = {
        'duration_ms': args.duration,
        'bandwidth': args.rate,
        'protocol': args.protocol,
        'parallel': args.parallel,
        'packet_size': args.packet_size
    }
    
    if args.pattern:
        results = generator.generate_pattern(
            num_bursts=args.pattern,
            interval_sec=args.interval,
            **burst_params
        )
        success_count = len([r for r in results if r.get('status') in ['success', 'timeout_ok']])
        print(f"\n[INFO] Pattern execution complete: {success_count}/{args.pattern} bursts successful")
    else:
        result = generator.generate_burst(**burst_params)
        if result:
            print("[INFO] Burst execution complete")
            sys.exit(0)
        else:
            print("[ERROR] Burst execution failed")
            sys.exit(1)


if __name__ == '__main__':
    main()
