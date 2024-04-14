// Cloud Storage bucket for storing build artifacts
resource "google_storage_bucket" "build_artifacts" {
  name     = "build-artifacts-bucket"
  location = "ASIA-NORTHEAST1"
}

// Cloud Build trigger for frontend
resource "google_cloudbuild_trigger" "frontend_build_trigger" {
  name        = "frontend-build-trigger"
  description = "Trigger for automated builds of the frontend"

  github {
    owner = "nozomi-koborinai"
    name  = "software-delivery-shield"
    push {
      branch = "main"
    }
  }

  included_files = ["frontend/**"]
  ignored_files  = ["infrastructure/**"]

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io//${var.project_id}/frontend", "./frontend"]
    }
  }
}

// Cloud Build trigger for backend
resource "google_cloudbuild_trigger" "backend_build_trigger" {
  name        = "backend-build-trigger"
  description = "Trigger for automated builds of the backend"

  github {
    owner = "nozomi-koborinai"
    name  = "software-delivery-shield"
    push {
      branch = "main"
    }
  }

  included_files = ["backend/**"]
  ignored_files  = ["infrastructure/**"]

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io//${var.project_id}/backend", "./backend"]
    }
  }
}

# // Binary Authorization policy for enforcing build provenance
# resource "google_binary_authorization_policy" "binauthz_policy" {
#   global_policy_evaluation_mode = "ENABLE"
#   default_admission_rule {
#     evaluation_mode         = "REQUIRE_ATTESTATION"
#     enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
#     require_attestations_by = ["projects/${var.project_id}/attestors/example-attestor"]
#   }
# }

# // Attestor for Binary Authorization
# resource "google_binary_authorization_attestor" "example_attestor" {
#   name = "example-attestor"
#   description = "Example Attestor for Binary Authorization"
#   attestation_authority_note {
#     note_reference = google_container_analysis_note.note.self_link
#     public_keys {
#       id = google_kms_crypto_key.crypto_key.crypto_key_version[0].id
#     }
#   }
# }