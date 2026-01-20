Subnets aren’t “in an Availability Zone” in Azure
A VNet and its subnets are regional (e.g., australiaeast) and not tied to AZ1/AZ2.


Resources (VMs, VMSS, AKS nodes, etc.) are what you place into Availability Zones.


If your real intent is “workloads are spread across AZ1 + AZ2”, you deploy the workloads in zone 1/2, but they can still live in the same subnet.


That said, some orgs still want separate subnets per zone for policy reasons (e.g., app-az1, app-az2). I’ll give you a module that supports both:
Default: 4 subnets total (workload, db, web, mgmt)


Optional: “zoned mode” creates 8 subnets (each tier split into az1 + az2)



What the module will create
VNet + subnets
Workload private subnet: no inbound from internet, outbound via NAT (optional)


DB subnet: only allows inbound from workload subnet on configurable DB ports


Web/Public subnet: allows inbound from internet (80/443 by default), outbound internet


Mgmt subnet (4th subnet): for bastion/jump/management (locked down)


Security controls
NSG per subnet with rules:


Workload: deny inbound from internet; allow from web/mgmt as you decide (default deny)


DB: allow from workload subnet to DB ports; deny internet inbound


Web: allow 80/443 inbound from Internet; allow outbound


Mgmt: allow inbound from your corporate IP ranges (variable)


Outbound internet for private subnets (recommended)
Optional NAT Gateway attached to workload + db subnets so they have outbound internet without public IPs.