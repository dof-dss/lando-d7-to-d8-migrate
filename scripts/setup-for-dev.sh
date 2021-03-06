#!/bin/bash

. /helpers/log.sh

lando_green "Cloning development repositories";

lando_blue "Cloning Migration Modules"
rm -rf /app/drupal8/web/modules/migrate/nidirect-migrations/
git clone git@github.com:dof-dss/nidirect-d8-mig-mods.git /app/drupal8/web/modules/migrate/nidirect-migrations/

lando_pink "Cloning Custom Modules"
rm -rf /app/drupal8/web/modules/custom
git clone git@github.com:dof-dss/nidirect-site-modules.git /app/drupal8/web/modules/custom

lando_yellow "Cloning Origins Modules"
rm -rf /app/drupal8/web/modules/origins
git clone git@github.com:dof-dss/nicsdru_origins_modules.git /app/drupal8/web/modules/origins

lando_pink "Cloning Origins Theme"
rm -rf /app/drupal8/web/themes/custom/nicsdru_origins_theme
git clone git@github.com:dof-dss/nicsdru_origins_theme.git /app/drupal8/web/themes/custom/nicsdru_origins_theme

lando_blue "Cloning NIDirect Theme"
rm -rf /app/drupal8/web/themes/custom/nicsdru_nidirect_theme
git clone git@github.com:dof-dss/nicsdru_nidirect_theme.git /app/drupal8/web/themes/custom/nicsdru_nidirect_theme

lando_green "Go develop!";