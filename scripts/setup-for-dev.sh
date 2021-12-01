#!/bin/bash

. /helpers/log.sh

lando_green "Cloning development repositories";

lando_pink "Cloning Custom Modules"
rm -rf /app/drupal/web/modules/custom
git clone git@github.com:dof-dss/nidirect-site-modules.git /app/drupal/web/modules/custom

lando_yellow "Cloning Origins Modules"
rm -rf /app/drupal/web/modules/origins
git clone git@github.com:dof-dss/nicsdru_origins_modules.git /app/drupal/web/modules/origins

lando_pink "Cloning Origins Theme"
rm -rf /app/drupal/web/themes/custom/nicsdru_origins_theme
git clone git@github.com:dof-dss/nicsdru_origins_theme.git /app/drupal/web/themes/custom/nicsdru_origins_theme

lando_blue "Cloning NIDirect Theme"
rm -rf /app/drupal/web/themes/custom/nicsdru_nidirect_theme
git clone git@github.com:dof-dss/nicsdru_nidirect_theme.git /app/drupal/web/themes/custom/nicsdru_nidirect_theme

lando_green "Go develop!";