#cloud-config
yum_repos:
  tailscale-stable:
    name: tailscale-stable
    enabled: true
    repo_gpgcheck: true
    gpgcheck: false
    baseurl: https://pkgs.tailscale.com/stable/amazon-linux/2/$basearch
    gpgkey: https://pkgs.tailscale.com/stable/amazon-linux/2/repo.gpg

packages:
  - tailscale
write_files:
  - path: /etc/sysctl.d/99-tailscale.conf
    content: |
      net.ipv4.ip_forward = 1
      net.ipv6.conf.all.forwarding = 1

runcmd:
  - sysctl --system
  - systemctl enable --now tailscaled
%{ if mode == "app-connector" ~}
  - tailscale up --authkey "${auth_key}" --advertise-connector --hostname "${hostname}" --accept-dns="${accept_dns}"
%{ else ~}
  - tailscale up --authkey "${auth_key}" --advertise-routes "${advertised_routes}" --hostname "${hostname}" --accept-dns="${accept_dns}"
%{ endif ~}
