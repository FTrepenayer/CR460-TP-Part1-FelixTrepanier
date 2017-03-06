///////////////////////////////////////////////////////////////////////////////////////
//J//U//M//P//H//O//S//T creation
resource "google_compute_instance" "jumphost" {
	name 			= "jumphost"
	machine_type	= "n1-standard-1"
	zone			= "us-east1-b"
	
	tags = ["jumphost"]


disk {
	image = "debian-cloud/debian-8"
}

//local SSD disk
disk {
	type 	= "local-ssd"
	scratch = true
}
	
//Public-Zone
network_interface {
	subnetwork = "${google_compute_subnetwork.ftrepenayer-public.name}"
	access_config {
	}
}

metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"

}

////////////////////////////////////////////////////////////////////////////////////////
//V//A//U//L//T creation
resource "google_compute_instance" "vault" {
	name 			= "vault"
	machine_type	= "n1-standard-1"
	zone			= "us-east1-b"
	
	tags = ["vault"]


disk {
	image = "coreos-cloud/coreos-stable"
}

//local SSD disk
disk {
	type 	= "local-ssd"
	scratch = true
}
	
//Public-Zone
network_interface {
	subnetwork = "${google_compute_subnetwork.ftrepenayer-public.name}"
	access_config {
	}
}

}

////////////////////////////////////////////////////////////////////////////////////////
//M//A//S//T//E//R creation
resource "google_compute_instance" "master" {
	name 			= "master"
	machine_type	= "n1-standard-1"
	zone			= "us-east1-b"
	
	tags = ["master"]


disk {
	image = "coreos-cloud/coreos-stable"
}

//local SSD disk
disk {
	type 	= "local-ssd"
	scratch = true
}
	
//Workload-Zone
network_interface {
	subnetwork = "${google_compute_subnetwork.ftrepenayer-workload.name}"
}

}

////////////////////////////////////////////////////////////////////////////////////////
//E//T//C//D//1 creation
resource "google_compute_instance" "etcd1" {
	name 			= "etcd1"
	machine_type	= "n1-standard-1"
	zone			= "us-east1-b"
	
	tags = ["etcd"]

disk {
    image = "coreos-cloud/coreos-stable"
}
	
//Backend-Zone
network_interface {
	subnetwork = "${google_compute_subnetwork.ftrepenayer-backend.name}"
}

}

////////////////////////////////////////////////////////////////////////////////////////
//E//T//C//D//2 creation
resource "google_compute_instance" "etcd2" {
	name 			= "etcd2"
	machine_type	= "n1-standard-1"
	zone			= "us-east1-b"
	
	tags = ["etcd"]

disk {
    image = "coreos-cloud/coreos-stable"
}
	
//Backend-Zone
network_interface {
	subnetwork = "${google_compute_subnetwork.ftrepenayer-backend.name}"
}

}

////////////////////////////////////////////////////////////////////////////////////////
//E//T//C//D//3 creation
resource "google_compute_instance" "etcd3" {
	name 			= "etcd3"
	machine_type	= "n1-standard-1"
	zone			= "us-east1-b"
	
	tags = ["etcd"]

disk {
    image = "coreos-cloud/coreos-stable"
}
	
//Backend-Zone
network_interface {
	subnetwork = "${google_compute_subnetwork.ftrepenayer-backend.name}"
}

}

////////////////////////////////////////////////////////////////////////////////////////
//I//N//S//T//A//N//C//E//////T//E//M//P//L//A//T//E//
resource "google_compute_instance_template" "workers-template" {
  name       		   = "workers"
  machine_type         = "f1-micro"
  can_ip_forward       = false


  disk {
    source_image = "coreos-cloud/coreos-stable"
    auto_delete = true
    boot = true
      }
	  
  network_interface {
    subnetwork = "${google_compute_subnetwork.ftrepenayer-workload.name}"
  }
  
  tags = ["workers"]

}

//G//R//O//U//P/////M//A//N//A//G//E//R//
resource "google_compute_instance_group_manager" "workers-template" {
  name        = "workers-template"

  base_instance_name = "worker"
  instance_template  = "${google_compute_instance_template.workers-template.self_link}"
  zone               = "us-east1-b"

}

//A//U//T//O//S//C//A//L//E//R//
resource "google_compute_autoscaler" "workers-template" {
  name   = "workers-template"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.workers-template.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
