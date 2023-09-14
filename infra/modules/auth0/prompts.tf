resource "auth0_prompt" "passwordless_prompt" {
  identifier_first           = true
  universal_login_experience = "new"
}

resource "auth0_prompt_custom_text" "content" {
  for_each = fileset(path.module, "/content/en/prompts/*.json")

  language = "en"
  prompt   = trimsuffix(basename(each.key), ".json")
  body     = file("${path.module}/${each.key}")
}

resource "auth0_branding_theme" "govuk_theme" {
  borders {
    button_border_weight = 2
    buttons_style        = "sharp"
    button_border_radius = 2
    input_border_weight  = 2
    inputs_style         = "sharp"
    input_border_radius  = 3
    widget_corner_radius = 0
    widget_border_weight = 0
    show_widget_shadow   = false
  }

  colors {
    primary_button            = "#00703c"
    primary_button_label      = "#ffffff"
    secondary_button_border   = "#000000"
    secondary_button_label    = "#1e212a"
    base_focus_color          = "#363540"
    base_hover_color          = "#000000"
    links_focused_components  = "#1d70b8"
    header                    = "#1e212a"
    body_text                 = "#1e212a"
    widget_background         = "#ffffff"
    widget_border             = "#ffffff"
    input_labels_placeholders = "#505a5f"
    input_filled_text         = "#000000"
    input_border              = "#000000"
    input_background          = "#ffffff"
    icons                     = "#505a5f"
    error                     = "#d4351c"
    success                   = "#1d70b8"
  }

  fonts {
    font_url            = ""
    links_style         = "underlined"
    reference_text_size = 19

    body_text {
      bold = false
      size = 87.5
    }

    buttons_text {
      bold = false
      size = 100
    }

    input_labels {
      bold = false
      size = 100
    }

    links {
      bold = false
      size = 87.5
    }

    title {
      bold = false
      size = 149
    }

    subtitle {
      bold = false
      size = 100
    }
  }

  page_background {
    page_layout          = "left"
    background_color     = "#ffffff"
    background_image_url = ""
  }

  widget {
    logo_position         = "left"
    logo_url              = "${var.admin_base_url}${var.app_logo_path}"
    logo_height           = 52
    header_text_alignment = "left"
    social_buttons_layout = "bottom"
  }
}
