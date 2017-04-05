# These overrides add configuration options to the settings panel
# See https://guides.spreecommerce.com/developer/view.html

# Add to the integrations panel
Deface::Override.new(
  :virtual_path  => "admin/settings/integration",
  :insert_top => "[data-hook='admin_settings_integrations']",
  :name          => "olark_settings",
  :partial => "admin/settings/olark_settings"
  )
