# module "projects_iam_bindings" {
#   source  = "terraform-google-modules/iam/google//modules/projects_iam"
#   version = "7.7.1"

#   projects = [var.project]

#   bindings = {
#     "roles/editor" = [
#       "user:gabe@hatchet.run",
#     ]
#     "roles/policyanalyzer.activityAnalysisViewer" = [
#       "serviceAccount:oneleet-901776eb554bc520@oneleet-external-identity.iam.gserviceaccount.com"
#     ]
#     "roles/artifactregistry.reader" = [
#       "serviceAccount:oneleet-901776eb554bc520@oneleet-external-identity.iam.gserviceaccount.com"
#     ]
#     "roles/cloudasset.viewer" = [
#       "serviceAccount:oneleet-901776eb554bc520@oneleet-external-identity.iam.gserviceaccount.com"
#     ]
#     "roles/cloudsql.viewer" = [
#       "serviceAccount:oneleet-901776eb554bc520@oneleet-external-identity.iam.gserviceaccount.com"
#     ]
#     "roles/compute.viewer" = [
#       "serviceAccount:oneleet-901776eb554bc520@oneleet-external-identity.iam.gserviceaccount.com"
#     ]
#     "roles/container.clusterViewer" = [
#       "serviceAccount:oneleet-901776eb554bc520@oneleet-external-identity.iam.gserviceaccount.com"
#     ]
#     "roles/iam.securityReviewer" = [
#       "serviceAccount:oneleet-901776eb554bc520@oneleet-external-identity.iam.gserviceaccount.com"
#     ]
#   }
# }