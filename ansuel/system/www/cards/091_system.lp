--pretranslated: do not change this file
 
-- Enable localization
gettext.textdomain('webui-core')

local ngx = ngx
local session = ngx.ctx.session
local format = string.format
local ui_helper = require("web.ui_helper")
local proxy = require("datamodel")
local modalPath = "/modals/system-modal.lp"
local syslog_present = "Disabled"
local sshlan_enabled = "Disabled"
local sshwan_enabled = "Disabled"
local iperf_enabled = "Disabled"
local tinsert = table.insert

local Syslog = proxy.get("uci.system.system.@system[0].log_ip", "uci.system.system.@system[0].log_filter_ip")
local SSH_lan = proxy.get("uci.dropbear.dropbear.@lan.enable")
local SSH_wan = proxy.get("uci.dropbear.dropbear.@wan.enable")
local iperf = proxy.get("uci.iperf.iperf.enable")
if Syslog and (Syslog[1].value ~= "" or Syslog[2].value ~= "") then
  syslog_present = "Enabled"
end
if SSH_lan and (SSH_lan[1].value == "1") then
  sshlan_enabled = "Enabled"
end
if SSH_wan and (SSH_wan[1].value == "1") then
  sshwan_enabled = "Enabled"
end
if iperf and (iperf[1].value == "1") then
  iperf_enabled = "Enabled"
end

local light_map = {
  Disabled = "off",
  Enabled = "green",
}
local syslog_state_map = {
  Disabled = T"syslog disabled",
  Enabled = T"syslog enabled",
}
local sshlan_state_map = {
  Disabled = T"SSH LAN disabled",
  Enabled = T"SSH LAN enabled",
}
local sshwan_state_map = {
  Disabled = T"SSH WAN disabled",
  Enabled = T"SSH WAN enabled",
}
local iperf_state_map = {
  Disabled = T"iperf disabled",
  Enabled = T"iperf enabled",
}

if session:hasAccess("/modals/system-modal.lp") then
    local modal_link = format("class=\"modal-link\" data-toggle=\"modal\" data-remote=\"%s\" data-id=\"device-modal\"",modalPath)
  ngx.print('\
<div class="span3">\
  <div class="smallcard">\
    ');  ngx.print( ui_helper.createCardHeader(T"System Extras", modalPath) ); ngx.print('\
    <div class="content card_bg" data-bg-text="&#xf085;">\
        ');  
        local html = {
          ui_helper.createSimpleLight(nil, syslog_state_map[syslog_present], { light = { class = light_map[syslog_present] } })
        }
        tinsert(html, ui_helper.createSimpleLight(nil, sshlan_state_map[sshlan_enabled], { light = { class = light_map[sshlan_enabled] } }) )
        tinsert(html, ui_helper.createSimpleLight(nil, sshwan_state_map[sshwan_enabled], { light = { class = light_map[sshwan_enabled] } }) )
        if iperf then
          tinsert(html, ui_helper.createSimpleLight(nil, iperf_state_map[iperf_enabled], { light = { class = light_map[iperf_enabled] } }) )
        end
        ngx.print(html)
    ngx.print('\
    </div>\
  </div>\
</div>\
');  
end
  ngx.print('\
'); 