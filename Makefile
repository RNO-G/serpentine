.PHONY: install enable start stop restart status clean

SYSTEMD_DIR := /etc/systemd/system
SERVICE_FILES := serpentine-copy.service serpentine-copy-meta.service
SCRIPT_DIR := /home/jade/serpentine

install: $(SERVICE_FILES)
	@echo "Installing systemd service files..."
	sudo cp $(SCRIPT_DIR)/serpentine-copy.service $(SYSTEMD_DIR)/
	sudo cp $(SCRIPT_DIR)/serpentine-copy-meta.service $(SYSTEMD_DIR)/
	sudo chmod 644 $(SYSTEMD_DIR)/serpentine-copy.service
	sudo chmod 644 $(SYSTEMD_DIR)/serpentine-copy-meta.service
	sudo systemctl daemon-reload
	@echo "Services installed and daemon reloaded"

enable:
	@echo "Enabling services..."
	sudo systemctl enable serpentine-copy serpentine-copy-meta
	@echo "Services enabled for boot"

start:
	@echo "Starting services..."
	sudo systemctl start serpentine-copy serpentine-copy-meta
	@echo "Services started"

stop:
	@echo "Stopping services..."
	sudo systemctl stop serpentine-copy serpentine-copy-meta
	@echo "Services stopped"

restart:
	@echo "Restarting services..."
	sudo systemctl restart serpentine-copy serpentine-copy-meta
	@echo "Services restarted"

status:
	@echo "=== serpentine-copy ==="
	sudo systemctl status serpentine-copy --no-pager
	@echo ""
	@echo "=== serpentine-copy-meta ==="
	sudo systemctl status serpentine-copy-meta --no-pager

logs:
	@echo "Showing recent logs for both services..."
	journalctl -u serpentine-copy -u serpentine-copy-meta -n 50 --no-pager

clean:
	@echo "Removing services..."
	sudo systemctl stop serpentine-copy serpentine-copy-meta
	sudo systemctl disable serpentine-copy serpentine-copy-meta
	sudo rm $(SYSTEMD_DIR)/serpentine-copy.service
	sudo rm $(SYSTEMD_DIR)/serpentine-copy-meta.service
	sudo systemctl daemon-reload
	@echo "Services removed"

help:
	@echo "Available targets:"
	@echo "  make install   - Install service files to $(SYSTEMD_DIR)"
	@echo "  make enable    - Enable services for boot"
	@echo "  make start     - Start services immediately"
	@echo "  make stop      - Stop services"
	@echo "  make restart   - Restart services"
	@echo "  make status    - Show service status"
	@echo "  make logs      - Show recent logs"
	@echo "  make clean     - Remove and disable services"
	@echo "  make help      - Show this help message"
