# googleworkspace_group_member.com_secrets_shared_secrets_member: Creating...
# ╷
# │ Error: googleapi: Error 403: Request had insufficient authentication scopes.
# │ Details:
# │ [
# │   {
# │     "@type": "type.googleapis.com/google.rpc.ErrorInfo",
# │     "domain": "googleapis.com",
# │     "metadata": {
# │       "method": "ccc.hosted.frontend.directory.v1.DirectoryMembers.Insert",
# │       "service": "admin.googleapis.com"
# │     },
# │     "reason": "ACCESS_TOKEN_SCOPE_INSUFFICIENT"
# │   }
# │ ]
# │ 
# │ More details:
# │ Reason: insufficientPermissions, Message: Insufficient Permission

# This would be how you would add a service account to a group with access to
# prj-example-com-secrets-665b Secret Manager secrets.

# resource "googleworkspace_group_member" "com_secrets_shared_secrets_member" {
#   group_id = "r_secretmanager_secretaccessor_shared_secrets@example.net"
#   email    = module.service_accounts.service_accounts_map["external-secrets"].email
# }
