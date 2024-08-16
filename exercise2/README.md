# Exercise 2: Cloud Storage System in Kubernetes

> Cloud Advanced

This files contains the instructions and the necessary steps to deploy a
[Nextclod](https://nextcloud.com/) instance in a Kubernetes cluster.
All the necessary files are provided in this folder, which follows the following
structure:

```zsh
 .
├──  klocal.sh
├── 󰗀 kub-devel-network.xml # Network configuration file
├──  network.sh 
├──  nextcloud # Nextcloud deployment manifests
│  ├──  ingress
│  ├──  metallb
│  ├──  secrets
│  ├──  values.yaml
│  └──  volumes
├──  README.md # This file
├──  scripts # Vagrant provisioning scripts
│  ├──  0_provisioning.sh
│  ├──  1_kubernetes.sh
│  ├──  2_utilities.sh
│  ├──  3_taint.sh
│  └──  4_nextcloud.sh
├── 󰢬 ssh # SSH keys
│  ├── 󰌆 id_rsa
│  └── 󰷖 id_rsa.pub
└── ⍱ Vagrantfile
```

## Requirements

The deployment of this project requires the following:

- [Vagrant](https://www.vagrantup.com/)
- [Libvirt](https://libvirt.org/)
- `vagrant-libvirt` plugin, which can be installed through the following command:

```zsh
vagrant plugin install vagrant-libvirt
```

> [!NOTE] For **Archlinux** users it might helpful to know that the libvirt plugin is not compatible with the ruby gems as currently shipped with the vagrant package in the Arch repos (which are up-to-date). This might cause an error such as Vagrant failed to properly resolve required dependencies. An alternative in order to use this plugin without such issues, is to use the container image via either Podman or Docker, as shown in the [official documentation](https://vagrant-libvirt.github.io/vagrant-libvirt/installation.html#docker--podman). Source: [Archwiki](https://wiki.archlinux.org/title/Vagrant) (July, 2024).

## Installation

The installation and deployment process is completely automated through the use
of the [provided scripts](scripts/). The following steps are sufficient for a
complete and fully funcional deployment.\
First of all, define the libvirt network using the [`network.sh`](./network.sh)
script:

```zsh
./network.sh up
```

Then, start the Vagrant machine:

```zsh
vagrant up
```

The installation process will begin. the provided [`Vagrantfile`](./Vagrantfile)
will setup a single node Kubernetes cluster based on the `Fedora/39-cloud-based`
box image. As soon as the process conclude, you can ssh into the machine with:

```zsh
vagrant ssh k01
```

and check the status of the cluster either with the installed `k9s` tool or with:

```zsh
[vagrant@k01 ~]$ kubectl get nodes
```

By running:

```zsh
[vagrant@k01 ~]$ kubectl get pods --all-namespaces
```

you can check the status of the pods and the services running in the cluster:
you should see the `nextcloud` namespace with the `nextcloud` pod running.\
To clean up and remove the virtual machine once you are done, you can run:

```zsh
vagrant destroy -f
```

from your host machine and all the resources will be removed.

## Deployment Details

As it can be seen from the [`4_nextcloud.sh`](./scripts/4_nextcloud.sh) script,
the deployment of the Nextcloud instance is done through the use of Helm charts.
in particular the [nextcloud chart](https://github.com/nextcloud/helm/tree/main/charts/nextcloud) is deployed with custom values defined in the [`values.yaml`](./nextcloud/values.yaml) file.\
Moreover, [MetalLB](https://metallb.universe.tf/) is used to provide a LoadBalancer service for the Nextcloud instance. It's installation has been done following the [guidelines](https://metallb.universe.tf/installation/) provided in the documentation and by defining a [custom pool of IP addresses](./nextcloud/metallb/pool.yaml) and a [Layer 2 advertisement](./nextcloud/metallb/l2advertisement.yaml) to be used by the LoadBalancer.\
Additionally, as explained in the MetalLB documentation, if you’re using kube-proxy in IPVS mode, since Kubernetes v1.14.2 you have to enable strict ARP mode. You can achieve this by editing kube-proxy config in current cluster:

```zsh
kubectl edit configmap -n kube-system kube-proxy
```

and manually set:

```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

> [!WARNING] Unfortually, this step has not been automated yet and has to be done manually by ssh into the master node once the cluster is running.

Finally, the [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is used to manage the incoming traffic. This has been installed according to [documentation](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/) through the use of Helm charts.\
Additional details about this deployment can be found in the report provided in this repository.

## Accessing the Nextcloud instance

Accessing the nextcloud instance from the host machine web browser it's possible
by port forwarding the nextcloud service to the host machine itself. This can be
done by first assuring that the nextcloud service is running:

```zsh
kubectl get svc -n nextcloud
```

anch check that the following LoadBalancer service is running with a similar IP
given by MetalLB:

```zsh
NAMESPACE        NAME                                  TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
nextcloud        my-nextcloud                          LoadBalancer   10.107.96.24     192.168.121.91   8080:30943/TCP               10m
```

Then, port forward the service to the host machine:

```zsh
kubectl port-forward service/my-nextcloud 8080:8080 --address 0.0.0.0 -n nextcloud
```

and access the Nextcloud instance from the host machine web browser at:

> [http://localhost:8080](http://localhost:8080)
