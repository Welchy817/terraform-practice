terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  credentials = "encryption.json"
  project     = "terraform-associate-practice"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_storage_bucket" "terraform-associate" {
  name          = "private-bucket-test-terraform-associate"
  location      = "US"
  force_destroy = true
}

resource "google_service_account" "storage-write" {
  account_id   = "gcp-cloud-storage-file-test"
  display_name = "Custom SA for VM Instance"
}

resource "google_service_account" "storage-no-write" {
  account_id   = "gcp-cloud-storage-file-no-test"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "storage-write-access" {
  name         = "storage-write"
  machine_type = "e2-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.storage-write.email
    scopes = ["storage-rw"]
  }
}

resource "google_compute_instance" "storage-no-access" {
  name         = "storage-no-access"
  machine_type = "e2-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.storage-no-write.email
    scopes = ["storage-ro"]
  }
}

resource "google_project_iam_custom_role" "cloud-storage-writer" {
  role_id     = "myCustomRole"
  title       = "Cloud Storage Write Test"
  description = "Custom role to add files to Cloud Storage bucket"
  permissions = [
    "storage.objects.create",
    "storage.objects.delete"]
}


resource "google_project_iam_binding" "vm-storage-bucket-writer" {
  project = "terraform-associate-practice"
  role    = "projects/terraform-associate-practice/roles/myCustomRole"

  members = [
    "serviceAccount:${google_service_account.storage-write.email}"
  ]
}

resource "google_project_iam_binding" "vm-service-account-admin" {
  project = "terraform-associate-practice"
  role    = "roles/iam.serviceAccountAdmin"

  members = [
    "serviceAccount:${google_service_account.storage-write.email}"
  ]
}