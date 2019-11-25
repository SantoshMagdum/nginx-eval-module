# vi:ft=

use lib 'lib';
use Test::Nginx::Socket;

plan tests => repeat_each() * 2 * blocks();

no_long_string();

run_tests();

__DATA__

=== TEST 1: eval
--- config
    location /echo {
        eval_subrequest_in_memory off;
        eval $a {
            echo_before_body BEFORE;
            proxy_pass $scheme://127.0.0.1:$server_port/hi;
        }
        echo '!!! [$a]';
    }
    location /hi {
        echo hi;
    }
--- request
GET /echo
--- response_body
!!! [hi]



=== TEST 2: eval
--- config
    location /echo {
        eval_subrequest_in_memory off;
        eval $a {
            default_type 'application/x-www-form-urlencoded';
            echo_before_body a=32;
            echo howdy;
        }
        echo '!!! [$a]';
    }
--- request
GET /echo
--- response_body
!!! []



=== TEST 3: eval with subrequest in memory
--- config
    location /echo {
        eval_subrequest_in_memory on;
        eval $a {
            echo_before_body BEFORE;
            proxy_pass $scheme://127.0.0.1:$server_port/hi;
        }
        echo '!!! [$a]';
    }
    location /hi {
        echo hi;
    }
--- request
GET /echo
--- response_body
!!! [hi]



=== TEST 4: eval with subrequest in memory
--- config
    location /echo {
        eval_subrequest_in_memory on;
        eval $a {
            echo_before_body BEFORE;
            proxy_pass $scheme://127.0.0.1:$server_port/hi;
        }
        echo '!!! [$a]';
    }
    location /hi {
        echo hi;
    }
--- request
GET /echo
--- response_body
!!! [hi]



=== TEST 5: eval with explicit buffer size
--- config
    location /echo {
        eval_subrequest_in_memory off;
        eval_buffer_size 3;
        eval $a {
            echo_before_body BEFORE;
            proxy_pass $scheme://127.0.0.1:$server_port/hi;
        }
        echo '!!! [$a]';
    }
    location /hi {
        echo hi;
    }
--- request
GET /echo
--- response_body
!!! [hi]



=== TEST 6: eval + exec bug
--- config
   location /test
   {
     echo_exec /initialize;
   }

   location /initialize
   {
     internal;
     eval_override_content_type 'text/plain';

     eval $id
     {
       #rewrite ^(.*)$ /id;
       proxy_pass http://127.0.0.1:$server_port/id;
     }
     echo $id;
   }
   location /id {
        echo hi;
   }
--- request
GET /test
--- response_body
--- SKIP



=== TEST 7: inherit parent request's query_string
--- config
    location /eval {
        eval_subrequest_in_memory off;
        eval $a {
            echo $arg_user;
        }
        echo '[$a]';
    }
--- request
GET /eval?user=howdy
--- response_body
[howdy]



=== TEST 8: eval in subrequests
--- config
    location /foo {
        add_before_body /bah;
        #echo_location_async /bah;
        echo done;
    }
    location /bah {
        eval_override_content_type 'text/plain';
        eval $foo {
            proxy_pass $scheme://127.0.0.1:$server_port/baz;
        }
        echo [$foo];
    }
    location /baz {
        echo baz;
    }
--- request
    GET /foo
--- response_body
--- SKIP



=== TEST 9: unescape uri
--- config
    location /echo {
        eval $a $b $c {
            proxy_pass $scheme://127.0.0.1:$server_port/encoded;
        }
        echo "a=[$a], b=[$b], c=[$c]";
    }
    location /encoded {
        default_type 'application/x-www-form-urlencoded';
        echo "a=&b=2&c=a+b%20c";
    }
--- request
GET /echo
--- response_body
a=[], b=[2], c=[a b c]



=== TEST 10: sanity check
--- config
    location /echo {
        eval_subrequest_in_memory off;
        #eval_subrequest_in_memory on;
        #eval_buffer_size 3;
        eval $a {
            #echo_before_body BEFORE;
            proxy_pass $scheme://127.0.0.1:$server_port/hi;
            #proxy_pass $scheme://127.0.0.1:1234/hi;
        }
        echo '!!! [$a]';
    }
    location /hi {
        echo helloooooooooooooooooooo;
    }
--- request
GET /echo
--- response_body
!!! [helloooooooooooooooooooo]
--- timeout: 10



=== TEST 11: eval with subrequest in memory
--- config
    location /echo {
        eval_subrequest_in_memory on;
        eval $a {
            proxy_connect_timeout 10ms;
            proxy_pass http://www.taobao.com:1234;
        }
        echo '!!! [$a]';
    }
    location /hi {
        echo hi;
    }
--- request
GET /echo
--- response_body
!!! [hi]
--- SKIP

