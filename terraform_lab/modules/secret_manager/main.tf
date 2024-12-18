/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


resource "google_secret_manager_secret" "default" {
  provider  = google-beta
  for_each  = var.disable ? {} : var.secrets
  project   = var.project_id
  secret_id = each.key
  labels    = lookup(var.labels, each.key, null)

  dynamic "replication" {
    for_each = each.value == null ? [""] : []
    content {
      auto {}
    }
  }

  dynamic "replication" {
    for_each = each.value == null ? [] : [each.value]
    iterator = locations
    content {
      user_managed {
        dynamic "replicas" {
          for_each = locations.value
          iterator = location
          content {
            location = location.value
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "default" {
  provider    = google-beta
  for_each    = var.disable ? {} : local.version_keypairs
  secret      = google_secret_manager_secret.default[each.value.secret].id
  enabled     = each.value.enabled
  secret_data = each.value.data
}
