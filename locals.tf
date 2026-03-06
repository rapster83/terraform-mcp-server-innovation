locals {
  storage_account_tags = merge(
    var.module_tags != null ? var.module_tags : {},
    var.storage_account_tags != null ? var.storage_account_tags : {}
  )
}
