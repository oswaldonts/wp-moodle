<?php
// Elementor y otros plugins llaman is_plugin_active() fuera del contexto admin.
// WordPress solo carga esta función en wp-admin — este mu-plugin la garantiza siempre.
if ( ! function_exists( 'is_plugin_active' ) ) {
    require_once ABSPATH . 'wp-admin/includes/plugin.php';
}
