class post_common (
  $aem_servlet_trigger_address  = 'process.svgiconprocess.svg',
  $aem_servlet_status_address   = 'process.iconprocessstatus.svg',
  $aem_user                     = 'orchestrator',
  $aem_password                 = $::aem_password ,
  $stack_prefix                 = $::stack_prefix ,
  $deployment_domain_type       = $::deployment_domain_type ,
  $deployment_target_scale      = $::deployment_target_scale ,

)
{

  if $deployment_domain_type == 'npe' {
   if $deployment_target_scale == 'full-set' {
       wait_for { 'triggers the processing job':
         query => "curl -IkL  -u ${aem_user}:${aem_password} https://${stack_prefix}-author-dispatcher.auspost.aem/${aem_servlet_trigger_address} -X GET",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
       }
       wait_for { 'determine whether it has completed':
         query => "curl -IkL  -u ${aem_user}:${aem_password} https://${stack_prefix}-author-dispatcher.auspost.aem/${aem_servlet_status_address} -X GET",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
     }
     }
     if $deployment_target_scale == 'consolidated' {

       wait_for { 'triggers the processing job':
         query => "curl -IkL  -u ${aem_user}:${aem_password} https://${stack_prefix}-aem-consolidated.auspost.aem:5432/${aem_servlet_trigger_address} -X GET",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
       }

       wait_for { 'determine whether it has completed':
         query => "curl -IkL -u ${aem_user}:${aem_password} https://${stack_prefix}-aem-consolidated.auspost.aem:5432/${aem_servlet_status_address} -X GET  ",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
     }
   }
  }

  if $deployment_domain_type == 'prod' {
     if $deployment_target_scale == 'full-set' {
       wait_for { 'triggers the processing job':
         query => "curl -IkL  -u ${aem_user}:${aem_password} https://${stack_prefix}-author-dispatcher.prod-auspost.aem/${aem_servlet_trigger_address} -X GET",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
       }
       wait_for { 'determine whether it has completed':
         query => "curl -IkL  -X GET -u ${aem_user}:${aem_password} https://${stack_prefix}-author-dispatcher.auspost.aem/${aem_servlet_status_address}",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
     }
     }
     if $deployment_target_scale == 'consolidated' {

       wait_for { 'triggers the processing job':
         query => "curl -IkL  -u ${aem_user}:${aem_password} https://${stack_prefix}-aem-consolidated.prod-auspost.aem:5432/${aem_servlet_trigger_address} -X GET",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
       }

       wait_for { 'determine whether it has completed':
         query => "curl -IkL  -X GET -u ${aem_user}:${aem_password} https://${stack_prefix}-aem-consolidated.prod-auspost.aem:5432/${aem_servlet_status_address}",
         regex => 'HTTP/1.1 200 OK',
         polling_frequency => 5,  # Wait up to 1 minutes (12 * 5 seconds).
         max_retries       => 12,
     }
   }
  }
}


include post_common
