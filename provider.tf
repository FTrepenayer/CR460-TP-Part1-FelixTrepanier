provider "google" {
	credentials = "${file("account.json")}"
	project		= "cr460-ftrepenayer"
	region		= "us-east1"
}
	
	
	