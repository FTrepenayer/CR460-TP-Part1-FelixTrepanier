///////////////////N///E///T///W///O///R///K///////////////////////////

resource "google_compute_network" "ftrepenayer-network" {
	name = "ftrepenayer-network"
	auto_create_subnetworks = "false"
}

//Reseau Public
resource "google_compute_subnetwork" "ftrepenayer-public" {
	name			 = "ftrepenayer-public"
	ip_cidr_range    = "172.16.1.0/24"
	network 		 = "${google_compute_network.ftrepenayer-network.self_link}"
	region			 = "us-east1"
}

//Reseau Workload
resource "google_compute_subnetwork" "ftrepenayer-workload" {
	name			 = "ftrepenayer-workload"
	ip_cidr_range    = "192.168.7.0/24"
	network 		 = "${google_compute_network.ftrepenayer-network.self_link}"
	region			 = "us-east1"
}

//Reseau Backend
resource "google_compute_subnetwork" "ftrepenayer-backend" {
	name			 = "ftrepenayer-backend"
	ip_cidr_range    = "192.168.11.0/24"
	network 		 = "${google_compute_network.ftrepenayer-network.self_link}"
	region			 = "us-east1"
}

/////////////////////F///I///R///E///W///A///L///L/////////////////////////

//Firewall - Public Rules
resource "google_compute_firewall" "public" {
	name	= "public"
	network = "${google_compute_network.ftrepenayer-network.name}"
	
	allow {
		protocol = "tcp"
		ports	 = ["80","22","443"]
		}
	//SOURCE: 		ANYWHERE
	//DESTINATION:
	target_tags =["jumphost","vault"]
		
	
}


//Firewall - Workload Rules
resource "google_compute_firewall" "Workload" {
	name	= "workload"
	network = "${google_compute_network.ftrepenayer-network.name}"
	
	allow {
		protocol = "tcp"
		ports	 = ["22"]
		}
	//SOURCE: reseau public
	source_ranges = ["172.16.1.0/24"]
	//DESTINATION:
	target_tags =["master","workers"]

}

//Firewall - Backend Rules
resource "google_compute_firewall" "Backend" {
	name	= "backend"
	network = "${google_compute_network.ftrepenayer-network.name}"
	
	allow {
		protocol = "tcp"
		ports	 = ["22","2379","2380"]
		}
	//reseau Public et Workload
	source_ranges = ["172.16.1.0/24","192.168.7.0/24"]
	//DESTINATION:
	target_tags =["etcd"]

}

////////////////////D/////N/////S/////////////////////////////

//Jumphost FQDN
resource "google_dns_record_set" "JumpHost" {
	name = "jump.ftrepenayer.cr460lab.com."
	type = "A"
	ttl  = 300
	
	managed_zone = "ftrepenayer"
	
	rrdatas = ["${google_compute_instance.jumphost.network_interface.0.access_config.0.assigned_nat_ip}"]
	
}

//Vault FQDN
resource "google_dns_record_set" "Vault" {
	name = "vault.ftrepenayer.cr460lab.com."
	type = "A"
	ttl  = 300
	
	managed_zone = "ftrepenayer"
	
	rrdatas = ["${google_compute_instance.vault.network_interface.0.access_config.0.assigned_nat_ip}"]
	
}
	