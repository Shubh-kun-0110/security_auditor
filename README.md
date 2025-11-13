# security_auditor/                                                                                                                                  
├── audit.sh                                                                                                     
└── modules/                                                                                 
    ├── check_world_writable.sh                                                 
    ├── check_empty_passwords.sh                                                              
    ├── check_services.sh                                                                   
    ├── check_open_ports.sh                                                                 
    └── remediate.sh                                                                            
    
Installation: mkdir -p ~/security_auditor/modules
              cd ~/security_auditor
              chmod +x audit.sh modules/*.sh
              
Running the Auditor: sudo ./audit.sh
                     sudo ./audit.sh --fix
                     
Generating Test Cases: To demonstrate and verify the auditor, you can intentionally create insecure conditions.Do this only in a VM or test machine

1. Test Case: World-Writable File
   Create : sudo touch /tmp/insecure_test.txt
            sudo chmod 666 /tmp/insecure_test.txt
   
2. Test Case: User Account with Empty Password
   Create : sudo useradd insecureuser
            sudo passwd -d insecureuser
   
4. Test Case: Open Unnecessary Port
   Install netcat-openbsd :: sudo apt install -y netcat-openbsd
   sudo nc -l 5555 & (Open a test port (5555))

 CONCLUSION : This Security Auditor provides a clean, modular, and safe framework for detecting common Linux               security issues.
   
