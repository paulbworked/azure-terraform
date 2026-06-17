locals {
  users = data.azuread_users.admin_users

  sb_loc_code = var.bus_stack == "dr" ? "euw" : var.sb_loc_code # Exception to accomodate the hard coding done by the devs

  enable_partitioning = var.sbns_sku == "Premium" ? false : true
  max_delivery_count  = 10
  queue_prefix        = "sbq"
  topic_prefix        = "sbt"
  subscription_prefix = "sbt"


  queue_names = {
    "email" = {
      session = false
    }
    "audit" = {
      session = false
    }
    "publish_request" = {
      session = false
    }
    "generate_request_message" = {
      session = false
    }
    "new_org_publish_request_message" = {
      session = false
    }
    "audit_v2" = {
      session = true
    }
    "import_id_claim" = {
      session = false
    }
    "import_data_view" = {
      session = false
    }
    "create_cm2_snapshot" = {
      session = false
    }
    "restore_cm2_snapshot" = {
      session = false
    }
    "audit-v3" = {
      session = true
    }
  }


  topic_names = {

    "user_upsert" = {
      report_service = true
      cm2            = true
      sm             = false
      session        = false
    }
    "org_upsert" = {
      report_service = true
      cm2            = true
      sm             = false
      session        = false
    }
    "study_upsert" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = false
    }
    "panel_upsert" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = false
    }
    "org-delete" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = false
    }
    "datatable_upsert" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = false
    }
    "import_id_claim_reply" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = true
    }
    "study_member_upsert" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = false
    }
    "study_function_upsert" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = false
    }
    "organisation_lov_upsert" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = false
    }
    "dataviewconfig_upsert" = {
      report_service = false
      cm2            = true
      sm             = true
      session        = false
    }
    "create_cm2_snapshot_reply" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = true
    }
    "restore_cm2_snapshot_reply" = {
      report_service = false
      cm2            = true
      sm             = false
      session        = true
    }
    "sm_study_member_upsert" = {
      report_service = false
      cm2            = false
      sm             = true
      session        = false
    }
  }

}
