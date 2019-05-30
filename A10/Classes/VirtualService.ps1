class VirtualService {
    [psobject]$Properties
    [psobject]$JsonObject
    VirtualService(){
$json = @"
{
    "virtual_service" : {
        "acl_natpool_binding_list" : [],
        "address" : "",
        "aflex_list" : [],
        "client_ssl_template" : "",
        "conn_reuse_template" : "",
        "connection_limit" : {
            "connection_limit" : 8000000,
            "connection_limit_action" : 0,
            "connection_limit_log" : 0,
            "status" : 0
        },
        "default_selection" : 1,
        "extended_stats" : 0,
        "ha_group" : {
        "ha_group_id" : 0
    },
    "http_template" : "",
    "name" : "",
    "pbslb_template" : "",
    "port" : 443,
    "protocol" : 12,
    "ram_cache_template" : "",
    "received_hop" : 1,
    "send_reset" : 1,
    "server_ssl_template" : "",
    "service_group" : "",
    "snat_against_vip" : 0,
    "source_ip_persistence_template" : "",
    "source_nat" : "",
    "stats_data" : 1,
    "status" : 1,
    "syn_cookie" : {
        "sack" : 0,
        "syn_cookie" : 0
    },
    "tcp_proxy_template" : "",
    "vport_acl_id" : 2,
    "vport_template" : "default"
    }
}
"@ | ConvertFrom-Json
        $This.Properties = $json.virtual_service.PSObject.Properties
        $This.JsonObject = $json
    }
}