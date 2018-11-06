---
layout: "google"
page_title: "Google: google_billing_account_iam_binding"
sidebar_current: "docs-google-billing-account-iam-binding"
description: |-
 Allows management of a single binding with an IAM policy for a Google Cloud Platform Billing Account.
---

# google\_billing_account_\_iam\_binding

Allows creation and management of a single binding within IAM policy for
an existing Google Cloud Platform Billing Account.

~> **Note:** This resource __must not__ be used in conjunction with
   `google_billing_account_iam_member` for the __same role__ or they will fight over
   what your policy should be.

## Example Usage

```hcl
resource "google_billing_account_iam_binding" "binding" {
  resource = "00AA00-000AAA-00AA0A"
  role     = "roles/billing.viewer"

  members = [
    "user:jane@example.com",
  ]
}
```

## Argument Reference

The following arguments are supported:

* `resource` - (Required) The billing account id.

* `role` - (Required) The role that should be applied.

* `members` - (Required) A list of users that the role should apply to.

## Attributes Reference

In addition to the arguments listed above, the following computed attributes are
exported:

* `etag` - (Computed) The etag of the billing account's IAM policy.

## Import

IAM binding imports use space-delimited identifiers; first the resource in question and then the role.  These bindings can be imported using the `resource` and role, e.g.

```
$ terraform import google_billing_account_iam_binding.binding "your-billing-account-id roles/viewer"
```