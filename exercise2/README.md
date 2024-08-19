# Exercise 2: Cloud Storage System in Kubernetes

> Cloud Advanced

This files contains the instructions and the necessary steps to deploy a
[Nextclod](https://nextcloud.com/) instance in a Kubernetes cluster.
All the necessary files are provided in this folder, which follows the following
structure:

```bash
📁 .
├── 🌐 kub-devel-network.xml # Network configuration file
├── network.sh 
├── 📁 minikube # Minikube deployment files
├── 📁 nextcloud # Nextcloud deployment manifests
│  ├── 📁 ingress
│  ├── 📁 metallb
│  ├── 📁 secrets
│  ├── 📄 values.yaml
│  └── 📁 volumes
├── 📜 README.md # This file
├── 📁 scripts # Vagrant provisioning scripts
│  ├── 0_provisioning.sh
│  ├── 1_kubernetes.sh
│  ├── 2_utilities.sh
│  ├── 3_taint.sh
│  └── 4_nextcloud.sh
├── 📁 ssh # SSH keys
│  ├── 🔑 id_rsa
│  └── 🔑 id_rsa.pub
└── 📜 Vagrantfile
```

## Requirements

The deployment of this project requires the following:

- [Vagrant](https://www.vagrantup.com/)
- [Libvirt](https://libvirt.org/)
- `vagrant-libvirt` plugin, which can be installed through the following command:

```bash
vagrant plugin install vagrant-libvirt
```

>[!NOTE]
>For **Archlinux** users it might helpful to know that the libvirt plugin is not compatible with the ruby gems as currently shipped with the vagrant package in the Arch repos (which are up-to-date). This might cause an error such as Vagrant failed to properly resolve required dependencies. An alternative in order to use this plugin without such issues, is to use the container image via either Podman or Docker, as shown in the [official documentation](https://vagrant-libvirt.github.io/vagrant-libvirt/installation.html#docker--podman). Source: [Archwiki](https://wiki.archlinux.org/title/Vagrant) (July, 2024).

**Optionally**, a minikube deployment is provided in the [`minikube/`](./minikube/)
folder. For that, the following requirements are needed on your local machine:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Helm](https://helm.sh/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [k9s](https://k9scli.io/) (*highly recommended*)

## Installation

The installation of the Nextcloud instance can be done either in a
Vagrant/Libvirt virtual machine or in a Minikube cluster following the
instructions below.

### Vagrant Installation

The installation and deployment process in Vagrant is completely automated through the use
of the [provided scripts](scripts/). The following steps are sufficient for a
complete and fully funcional deployment.\
First of all, define the libvirt network using the [`network.sh`](./network.sh)
script:

```bash
./network.sh up
```

Then, start the Vagrant machine:

```bash
vagrant up
```

The installation process will begin. the provided [`Vagrantfile`](./Vagrantfile)
will setup a single node Kubernetes cluster based on the `Fedora/39-cloud-based`
box image. As soon as the process conclude, you can ssh into the machine with:

```bash
vagrant ssh k01
```

and check the status of the cluster either with the installed `k9s` tool or with:

```bash
[vagrant@k01 ~]$ kubectl get nodes
```

By running:

```bash
[vagrant@k01 ~]$ kubectl get pods --all-namespaces
```

you can check the status of the pods and the services running in the cluster:
you should see the `nextcloud` namespace with the `nextcloud` pod running.\
This automated deployment also includes the installation ofthe MetalLB
controller with a given pool of IP addresses. Recall that those IP addresses
must be included in the same subnet of the Vagrant machine. Check that the
provided configuration satisfies your needs by getting the machine ip with:

```bash
vagrant ssh-config
```

Otherwise adjust the ip range in the [`metalLB configuration file`](./nextcloud/metallb/metallb-config.yaml).\
To clean up and remove the virtual machine once you are done, you can run:

```bash
vagrant destroy -f
```

from your host machine and all the resources will be removed.

### Minikube Installation

First of all, start the minikube cluster:

```bash
minikube start
```

In my case, I used docker as the driver for minikube, but you can use any other
driver by specifying it with the `--driver=<driver>` flag.\
Then, you need to enable the `metallb` and `ingress` addons:

```bash
minikube addons enable metallb
minikube addons enable ingress
```

Finally, all the needed resources can be deployed by entering the
[`minikube/`](./minikube/) folder and running inside:

```bash
cd minikube
./minikube-deploy.sh
```

>[!NOTE]
>In case the automated script fails, try running the commands one by one manually and monitor the deployment of the resources: sometimes, depending on the hardware specs of the machine, some resources might take longer to be deployed.

The same considerations made above about the MetalLB configuration apply here as
well. In this case you can get the minikube ip with:

```bash
minikube ip
```

To clean up everything and remove the minikube cluster when you're finished, you can run:

```bash
minikube delete
```

## Deployment Details

As it can be seen from the [`4_nextcloud.sh`](./scripts/4_nextcloud.sh) script,
the deployment of the Nextcloud instance is done through the use of Helm charts.
in particular the [nextcloud chart](https://github.com/nextcloud/helm/tree/main/charts/nextcloud) is deployed with custom values defined in the [`values.yaml`](./nextcloud/values.yaml) file.\
Moreover, [MetalLB](https://metallb.universe.tf/) is used to provide a LoadBalancer service for the Nextcloud instance. It's installation has been done following the [guidelines](https://metallb.universe.tf/installation/) provided in the documentation and by defining a [custom pool of IP addresses](./nextcloud/metallb/metallb-config.yaml) and a [Layer 2 advertisement](./nextcloud/metallb/metallb-config.yaml) to be used by the LoadBalancer.\
Additionally, as explained in the MetalLB documentation, if you’re using kube-proxy in IPVS mode, since Kubernetes v1.14.2 you have to enable strict ARP mode. You can achieve this by editing kube-proxy config in current cluster:

```bash
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

>[!WARNING]
>Unfortunately, as of now, this step has not been automated yet and has to be done manually by ssh into the master node once the cluster is running.

Finally, the [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is used to manage the incoming traffic. This has been installed according to [documentation](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/) through the use of Helm charts.\
Additional details about this deployment can be found in the report provided in this repository.

## Accessing the Nextcloud instance

### Accessign with Vagrant deployment

Accessing the nextcloud instance from the host machine web browser it's possible
by port forwarding the nextcloud service to the host machine itself. This can be
done by first assuring that the nextcloud service is running:

```bash
kubectl get svc -n nextcloud
```

anch check that the following LoadBalancer service is running with a similar IP
given by MetalLB:

```bash
NAMESPACE   NAME            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)           AGE
nextcloud   my-nextcloud    LoadBalancer   10.107.96.24    192.168.121.91   8080:30943/TCP    10m
```

Then, port forward the service to the host machine:

```bash
kubectl port-forward service/my-nextcloud 8080:8080 --address 0.0.0.0 -n nextcloud
```

and access the Nextcloud instance from the host machine web browser at:

> [http://localhost:8080](http://localhost:8080)

The port forwarding should be automatically set-up as specified in the
[`Vagrantfile`](./Vagrantfile).

### Accessing with Minikube deployment

Accessing the nextcloud instance from the host machine web browser in the case
of the minikube deployment has been made easier as we can take advantage of the
ingrss addon. After all the installation step have been completed, check that
the ingress is up and running with:

```bash
kubectl get ingress -n nextcloud
```

The output should be similar to:

```bash
NAME           CLASS   HOSTS             ADDRESS        PORTS   AGE
my-nextcloud   nginx   nextcloud.local   192.168.49.2   80      127m
```

After that, get the IP address of the minikube cluster with:

```bash
minikube ip
```

For instance, in my case the IP address is `192.168.49.2`.\
Then, add the following line to your `/etc/hosts` file with the obtained
address:

```bash
192.168.49.2 nextcloud.local
```

and access the Nextcloud instance from the host machine web browser at:

> [https://nextcloud.local](http://nextcloud.local)
