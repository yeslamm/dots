.PHONY: all sysconfigs keyd logind scx

all: sysconfigs

sysconfigs: keyd logind scx
	@echo "==> All system configurations deployed successfully."

keyd:
	@echo "==> Deploying keyd configuration..."
	@sudo install -Dm644 sysconfigs/keyd/default.conf /etc/keyd/default.conf
	@sudo systemctl daemon-reload
	@sudo systemctl enable --now keyd.service
	@sudo usermod -aG keyd $$USER

logind:
	@echo "==> Deploying systemd-logind configuration..."
	@sudo install -Dm644 sysconfigs/systemd/login.conf /etc/systemd/logind.conf.d/login.conf

scx:
	@echo "==> Deploying Sched-EXT (scx_lavd) configuration..."
	@sudo install -Dm644 sysconfigs/scx/scx /etc/default/scx
	@sudo install -Dm644 sysconfigs/systemd/scx.service /etc/systemd/system/scx.service
	@sudo systemctl daemon-reload
	@sudo systemctl enable --now scx.service
