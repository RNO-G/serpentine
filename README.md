# Serpentine

Simple automated file synchronization from RNO-G sites in Greenland to DESY using rsync, managed by systemd.

## Overview

Serpentine provides two systemd services that continuously synchronize data and metadata from local storage to a remote DESY server. The services run as background processes with automatic restart capabilities and watchdog monitoring.

### Services

**`serpentine-copy`** — Copies raw data files from `/data/outbox` to DESY
- Transfer rate: 48 kB/s
- Rsync timeout: 1 hour per sync cycle
- Source directory: `/data/outbox`
- Removes synced files from source after transfer
- Managed by systemd (runs continuously)

**`serpentine-copy-meta`** — Copies metadata files from `/data/ingress` to DESY
- Transfer rate: 48 kB/s
- Sync interval: 10 seconds between cycles
- Source directory: `/data/ingress`
- Excludes logs, waveforms, headers, and other large data types
- Managed by systemd (runs continuously)

**`copy-data`** — Manual utility for copying specific files to DESY
- Transfer rate: 24 kB/s
- Source directory: `/data/rootified/`
- One-time transfer (not a service)
- Usage: `./copy-data <filelist.txt>`
  - `filelist.txt` should contain relative paths to files in `/data/rootified/`
  - Files are expected to follow the directory structure: `stationXX/runYYYYYY/file`

## Installation

### Prerequisites
- Root access or sudo privileges
- rsync installed
- systemd available
- SSH key authentication configured for DESY server

### Quick Start

```bash
make install    # Install service files to /etc/systemd/system
make enable     # Enable services on boot
make start      # Start services immediately
```

Alternatively, install step-by-step:

```bash
sudo make install
sudo make enable
sudo systemctl start serpentine-copy serpentine-copy-meta
```

## Configuration

Edit the bash scripts to customize rsync behavior:

**`serpentine-copy`** and **`serpentine-copy-meta`** — Modify these variables:
- `DESTHOST` — Remote server hostname
- `DESTUSER` — SSH user for remote connection
- `DESTDIR` — Remote destination directory
- `RATE` — Transfer rate limit (kB/s)
- `PERMS` — File/directory permissions after sync
- `--exclude` — File patterns to skip

### Manual Data Transfer with copy-data

The `copy-data` script transfers specific files on-demand (not as a background service):

1. Create a text file listing the relative paths of files to copy:

```
station01/run001/data.root
station02/run002/data.root
station03/run003/data.root
```

2. Run the script:

```bash
./copy-data filelist.txt
```

Files must be in `/data/rootified/` and follow the directory structure `stationXX/runYYYYYY/file`.

## Management

### Common Commands

```bash
make status             # Check service status
make logs               # Show recent logs
make restart            # Restart services
make stop               # Stop services
make start              # Start services
make clean              # Uninstall and disable services
make help               # Show all available commands
```

### Manual systemctl Commands

```bash
systemctl status serpentine-copy
systemctl stop serpentine-copy
systemctl restart serpentine-copy
journalctl -u serpentine-copy -f      # Follow logs in real-time
```

## Monitoring

### Logs

View logs using journalctl:

```bash
# Recent logs
journalctl -u serpentine-copy -n 50

# Real-time logs
journalctl -u serpentine-copy -f

# Combined logs for both services
journalctl -u serpentine-copy -u serpentine-copy-meta -n 100
```

### Watchdog

Both services include a watchdog timer. The scripts ping systemd every loop iteration via `systemd-notify WATCHDOG=1`. If a service becomes unresponsive, systemd will automatically restart it.

## Service Details

### systemd Configuration

Key service settings:

- **`Type=simple`** — Service runs in foreground
- **`Restart=always`** — Auto-restart on failure
- **`RestartSec=10`** — Wait 10 seconds between restarts
- **`WatchdogSec`** — Timeout for watchdog monitoring (varies per service)
- **`User=rno-g`** — Runs as rno-g user
- **`StandardOutput=journal`** — Logs to systemd journal

## Troubleshooting

### Service won't start

Check logs for errors:
```bash
journalctl -u serpentine-copy -n 20 --no-pager
```

Common issues:
- SSH key not set up for passwordless authentication
- Source/destination directories don't exist
- Permission issues with data directories

### High CPU usage

Check if rsync is stuck or endlessly restarting:
```bash
ps aux | grep rsync
make status
```

### Watchdog timeout

If you see "watchdog timeout" errors:
- The script may be too slow; consider increasing `WatchdogSec` in the service file
- Check network connectivity to DESY server

## File Structure

```
serpentine/
├── serpentine-copy              # Main data sync script (continuous)
├── serpentine-copy-meta         # Metadata sync script (continuous)
├── copy-data                    # Manual file copy utility (on-demand)
├── serpentine-copy.service      # Systemd service for serpentine-copy
├── serpentine-copy-meta.service # Systemd service for serpentine-copy-meta
├── Makefile                     # Installation and management automation
└── README.md                    # This file
```
