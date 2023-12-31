class ClientSslTemplate {
    [psobject]$Properties
    [psobject]$JsonObject
    ClientSslTemplate(){
$json = @"
        {
            "client_ssl_template" : {
                "ca_cert_list" : [],
                "ca_cert_name" : "",
                "ca_key_name" : "",
                "ca_pass_phrase" : "",
                "cache_size" : 0,
                "cert_name" : "",
                "chain_cert_name" : "",
                "cipher_list" : [
                    {
                    "cipher" : 0
                    }
                ],
                "cipher_tmpl_name" : "",
                "client_cert_rev_list" : "",
                "client_check_mode" : 2,
                "client_close_notify" : 0,
                "key_name" : "",
                "name" : "",
                "pass_phrase" : "",
                "server_name_indication_list" : [],
                "ssl_false_stat" : 1,
                "ssl_forward_proxy" : 1
            }
        }
"@ | ConvertFrom-Json
        $This.Properties = $json.client_ssl_template.PSObject.Properties
        $This.JsonObject = $json
    }
}