gettext.textdomain('webui-core')

local proxy = require("datamodel")
local ui_helper = require("web.ui_helper")
local content_helper = require("web.content_helper")
local message_helper = require("web.uimessage_helper")
local post_helper = require("web.post_helper")
format, match = string.format, string.match

local content = {
    sfp_enabled = "uci.env.rip.sfp",
}
content_helper.getExactContent(content)
local sfp = content["sfp_enabled"]
    
local ethname = proxy.get("sys.eth.port.@eth4.status")
if ethname and ethname[1].value then
    ethname =  "eth4"
else
    ethname =  "eth3"
end

local function get_wansensing() 
	if proxy.get("uci.wansensing.global.enable") then
		return proxy.get("uci.wansensing.global.enable")[1].value
	end
	return ""
end

local function get_wan_mode()
	if proxy.get("uci.network.config.wan_mode") then
		return proxy.get("uci.network.config.wan_mode")[1].value 
	end
	return ""
end

local function findwan(interface)
	for i,v in ipairs(proxy.getPN("uci.network.device.", true)) do
		local result = match(v.path, "uci%.network%.device%.@.*".. interface .. ".*%.")
		if result then
			return (result:gsub("uci%.network%.device%.",""):gsub("%.",""))
		end
	end
	
	return nil
end

local function restartNetwork() 
	local ubus = require("ubus")

	local conn = ubus.connect()
	if not conn then
		return "Failed to connect to ubusd"
	end
	
	conn:call("network", "restart", {})
	
	conn:close()
end

local function bridge(mode) 
	local ifnames = proxy.get("uci.network.interface.@lan.ifname")[1].value
	local wan_ifname = proxy.get("uci.network.interface.@wan.ifname")[1].value
	local state = proxy.get("uci.network.config.wan_mode")
	if mode == "enable" then
		proxy.set({
			["uci.wansensing.global.enable"] = '0',
			["uci.network.interface.@wan.enabled"] = '0',
			["uci.network.interface.@wan.auto"] = '0',
			["uci.network.interface.@wan6.enabled"] = '0',
			["uci.network.interface.@wwan.enabled"] = '0',
			["uci.wireless.wifi-device.@radio_2G.state"] = '0',
			["uci.wireless.wifi-device.@radio_5G.state"] = '0',
			["uci.mmpbx.mmpbx.@global.enabled"] = '0',
			["uci.dhcp.dhcp.@lan.ignore"] = '1',
			["uci.cwmpd.cwmpd_config.state"] = '0',
			["uci.mobiled.device_defaults.enabled"] = '0',
			["uci.network.interface.@lan.ifname"] = ifnames ..' '.. wan_ifname,
			["uci.network.config.wan_mode"] = 'bridge',
		})
	elseif not ( state and state[1].value == "bridge" ) then
		return
	else
		local wan_proto = proxy.get("uci.network.interface.@wan.proto")
		
		proxy.set({
			["uci.wansensing.global.enable"] = '1',
			["uci.network.interface.@wan.enabled"] = '1',
			["uci.network.interface.@wan.auto"] = '1',
			["uci.network.interface.@wan6.enabled"] = '1',
			["uci.network.interface.@wwan.enabled"] = '1',
			["uci.wireless.wifi-device.@radio_2G.state"] = '1',
			["uci.wireless.wifi-device.@radio_5G.state"] = '1',
			["uci.mmpbx.mmpbx.@global.enabled"] = '1',
			["uci.dhcp.dhcp.@lan.ignore"] = '0',
			["uci.cwmpd.cwmpd_config.state"] = '1',
			["uci.mobiled.device_defaults.enabled"] = '1',
			["uci.network.interface.@lan.ifname"] = string.gsub(string.gsub(ifnames, wan_ifname, ""), "%s$", ""),
			["uci.network.config.wan_mode"] = wan_proto and wan_proto[1].value or "dhcp",
		})
	end
	
	restartNetwork()

    return
end

local tablecontent = {}
tablecontent[#tablecontent + 1] = {
    name = "adsl",
    default = false,
    description = "ADSL2+",
    view = "broadband-adsl-advanced.lp",
    card = "002_broadband_xdsl.lp",
    check = function()
        if get_wansensing() == "1" then
            local L2 = proxy.get("uci.wansensing.global.l2type")[1].value
            if L2 == "ADSL" then
                return true
            end
			
        else
            if not ( get_wan_mode() == "bridge" ) then
                local ifname = proxy.get("uci.network.interface.@wan.ifname")[1].value

                local iface = match(ifname, "atm")

                if iface then
                    return true
                end
            end
        end
    end,
    operations = function()
		bridge("check")
		local interface = findwan("atm") or "@wanatmwan"
        local difname = proxy.get("uci.network.device." .. interface .. ".ifname")
        if difname then
            local dname = proxy.get("uci.network.device." .. interface .. ".name")[1].value
            difname = proxy.get("uci.network.device." .. interface .. ".ifname")[1].value
            if difname ~= "" and difname ~= nil then
                proxy.set("uci.network.interface.@wan.ifname", dname)
            else
                proxy.set("uci.network.interface.@wan.ifname", "atmwan")
            end
        else
            proxy.set("uci.network.interface.@wan.ifname", "atmwan")
        end
        if sfp == 1 then
            proxy.set("uci.ethernet.globals.eth4lanwanmode", "1")
        end
        if ethname == "eth3" then
            local ifnames = proxy.get("uci.network.interface.@lan.ifname")[1].value
            proxy.set({
                ["uci.network.interface.@lan.ifname"] = ifnames ..' '.. ethname,
                ["uci.ethernet.port.@eth3.wan"] = "0"
            })
        end
        proxy.set("uci.wansensing.global.l2type", "ADSL")
    end,
}
tablecontent[#tablecontent + 1] = {
    name = "vdsl",
    default = true,
    description = "VDSL2",
    view = "broadband-vdsl-advanced.lp",
    card = "002_broadband_xdsl.lp",
    check = function()

        if get_wansensing() == "1" then
            local L2 = proxy.get("uci.wansensing.global.l2type")[1].value
            if L2 == "VDSL" then
                return true
            end
        else
            if not ( get_wan_mode() == "bridge" ) then
                local ifname = proxy.get("uci.network.interface.@wan.ifname")[1].value
        
                local iface = match(ifname, "ptm0")
        
                if iface then
                    return true
                end
            end
        end
    end,
    operations = function()
		bridge("check")
		local interface = findwan("ptm") or "@wanptm0"
        local difname = proxy.get("uci.network.device." .. interface .. ".ifname")
        if difname then
            local dname = proxy.get("uci.network.device." .. interface .. ".name")[1].value
            difname = proxy.get("uci.network.device." .. interface .. ".ifname")[1].value
            if difname ~= "" and difname ~= nil then
                proxy.set("uci.network.interface.@wan.ifname", dname)
            else
                proxy.set("uci.network.interface.@wan.ifname", "ptm0")
            end
        else
            proxy.set("uci.network.interface.@wan.ifname", "ptm0")
        end
        if sfp == 1 then
            proxy.set("uci.ethernet.globals.eth4lanwanmode", "1")
        end
        if ethname == "eth3" then
            local ifnames = proxy.get("uci.network.interface.@lan.ifname")[1].value
            proxy.set({
                ["uci.network.interface.@lan.ifname"] = ifnames ..' '.. ethname,
                ["uci.ethernet.port.@eth3.wan"] = "0"
            })
        end
        proxy.set("uci.wansensing.global.l2type", "VDSL")
    end,
}
tablecontent[#tablecontent + 1] = {
    name = "bridge",
    default = false,
    description = "Bridge Mode",
    view = "broadband-bridge.lp",
    card = "002_broadband_bridge.lp",
    check = function()
        if ( get_wansensing() == "0" ) and ( get_wan_mode() == "bridge" ) then
            return true
        end
    end,
    operations = function()
		bridge("enable")
	end,
}
tablecontent[#tablecontent + 1] = {
    name = "ethernet",
    default = false,
    description = "Ethernet",
    view = "broadband-ethernet-advanced.lp",
    card = "002_broadband_ethernet.lp",
    check = function()

        if get_wansensing() == "1" then
            local L2 = proxy.get("uci.wansensing.global.l2type")[1].value
            if L2 == "ETH" then
                return true
            end
        else
            if not ( get_wan_mode() == "bridge" ) then
                local ifname = proxy.get("uci.network.interface.@wan.ifname")[1].value

                local iface = match(ifname, ethname)
                if sfp == 1 then
                    local lwmode = proxy.get("uci.ethernet.globals.eth4lanwanmode")[1].value
                    if iface and lwmode == "0" then
                        return true
                    end
                else
                    if iface then
                        return true
                    end
                end
            end
        end
    end,
    operations = function()
		bridge("check")
		local interface = findwan(ethname) or "@waneth4"
        local difname = proxy.get("uci.network.device." .. interface .. ".ifname")
        if difname then
            local dname = proxy.get("uci.network.device." .. interface .. ".name")[1].value
            difname = proxy.get("uci.network.device." .. interface .. ".ifname")[1].value
            if difname ~= "" and difname ~= nil then
                proxy.set("uci.network.interface.@wan.ifname", dname)
            else
                proxy.set("uci.network.interface.@wan.ifname", ethname)
            end
        else
            proxy.set("uci.network.interface.@wan.ifname", ethname)
        end
        if sfp == 1 then
            proxy.set("uci.ethernet.globals.eth4lanwanmode", "0")
        end
        if ethname == "eth3" then
            local ifnames = proxy.get("uci.network.interface.@lan.ifname")[1].value
            proxy.set({
                ["uci.network.interface.@lan.ifname"] = string.gsub(string.gsub(ifnames, ethname, ""), "%s$", ""),
                ["uci.ethernet.port.@eth3.wan"] = "1"
            })
        end
        proxy.set("uci.wansensing.global.l2type", "ETH")
    end,
}

if sfp == 1 then
    tablecontent[#tablecontent + 1] = {
        name = "gpon",
        default = false,
        description = "GPON",
        view = "broadband-gpon-advanced.lp",
        card = "002_broadband_gpon.lp",
        check = function()
            if get_wansensing() == "1" then
                local L2 = proxy.get("uci.wansensing.global.l2type")[1].value
                if L2 == "SFP" then
                    return true
                end
            else
                if not ( get_wan_mode() == "bridge" ) then
                    local ifname = proxy.get("uci.network.interface.@wan.ifname")[1].value

                    local iface = match(ifname, ethname)

                    if sfp == 1 then
                        local lwmode = proxy.get("uci.ethernet.globals.eth4lanwanmode")[1].value
                        if iface and lwmode == "1" then
                            return true
                        end
                    else
                        if iface then
                            return true
                        end
                    end
                end
            end
        end,
        operations = function()
			bridge("check")
			local interface = findwan(ethname) or "@waneth4"
            local difname = proxy.get("uci.network.device." .. interface .. ".ifname")
            if difname then
                local dname = proxy.get("uci.network.device." .. interface .. ".name")[1].value
                difname = proxy.get("uci.network.device." .. interface .. ".ifname")[1].value
                if difname ~= "" and difname ~= nil then
                    proxy.set("uci.network.interface.@wan.ifname", dname)
                else
                    proxy.set("uci.network.interface.@wan.ifname", ethname)
                end
            else
                proxy.set("uci.network.interface.@wan.ifname", ethname)
            end
            proxy.set("uci.ethernet.globals.eth4lanwanmode", "1")
            proxy.set("uci.wansensing.global.l2type", "SFP")
        end,
    }
end
return tablecontent