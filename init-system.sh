#!/bin/bash

# System Configuration
cat > /etc/security/limits.d/ollama.conf << EOF
*       soft    memlock    unlimited
*       hard    memlock    unlimited
EOF

# NVIDIA Configuration
cat > /etc/nvidia-container-runtime/config.toml << EOF
disable-require = false
[nvidia-container-cli]
environment = []
debug = "/var/log/nvidia-container-toolkit.log"
EOF

# Sysctl Configuration
cat > /etc/sysctl.d/99-ollama.conf << EOF
# CPU et memory Performance
vm.swappiness=10
vm.dirty_ratio=60
vm.dirty_background_ratio=2
vm.vfs_cache_pressure=50

# Scheduling Optimization
kernel.sched_autogroup_enabled=0
kernel.sched_child_runs_first=1
kernel.sched_energy_aware=0
kernel.sched_rt_period_us=1000000
kernel.sched_rt_runtime_us=990000
kernel.sched_cfs_bandwidth_slice_us=3000

# Network Optimization
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.netdev_max_backlog=30000
net.ipv4.tcp_max_syn_backlog=8096
net.ipv4.tcp_max_tw_buckets=2000000
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=10

# Huge Pages
vm.nr_hugepages=8192
EOF

# Create required directories
cd docker
mkdir -p certs
chmod 755 certs

# Generate SSL self-signed certificates
openssl req -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout docker/certs/cert.key \
    -out docker/certs/cert.crt \
    -subj "/CN=ollama.local" \
    -addext "subjectAltName = DNS:ollama.local"

# Define certificates permissions
chmod 644 certs/cert.crt
chmod 600 certs/cert.key
cd ..

# Local hosts configuration
if ! grep -q "ollama.local" /etc/hosts; then
    echo "127.0.0.1 ollama.local" >> /etc/hosts
fi

# Dependencies & monitoring tools installation
apt-get update && apt-get install -y \
    prometheus-node-exporter \
    nvidia-container-toolkit \
    curl \
    htop \
    iotop

# Apply sysctl settings
sysctl -p /etc/sysctl.d/99-ollama.conf

# Activate system services
systemctl enable --now prometheus-node-exporter

echo "Installation completed successfully"
echo "Certificates generated in ./certs/"
echo "Local domains added to /etc/hosts"
echo "===================================="
echo "-> To start Open WebUI, run: make up"
