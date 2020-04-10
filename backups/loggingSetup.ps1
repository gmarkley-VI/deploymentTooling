New-NetFirewallRule -DisplayName "Enable console logs" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 10250 -EdgeTraversalPolicy Allow
