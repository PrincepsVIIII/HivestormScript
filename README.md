# HivestormScript
**This script only works on Windows OS**

##How to Run the Script
1. Download the script and the security template
2. Move the security template to the "C:\" directory and confirm the full name is "C:\HivestormTemplate.inf"
3. Run the script to open the Security Menu



The Security Menu has the following 5 options

1. Configure Audit Policies
2. Configure Account Policies
3. Locate and Remove Media Files
4. Disable Insecure Services
5. Run All Security Functions
0. Exit

Enter the corresponding number (0-5) to select your function

###Important notes
- TEXT FILES ARE CONSIDERED MEDIA FILES
- BY DEFAULT THIS SCRIPT WILL DISABLE REMOTE DESKTOP SERVICES
- "Locate and Remove Media Files" will prompt for deletion confirmation before each file is deleted.
- Make sure you do not delete any media files that may be crucial to the Forensic Questions or other important media files.
- This is designed for Windows Server 2016 and Windows 10. It has as of yet only been tested on Windows 10. I will update this shortly when I finish testing on Windows Server 2016.

##Each Function Explained

###Configure Audit Policies
This is honestly a redundant and possibly non-functional method. When I last tested this it worked, however I have little faith that it will continue to do so. The Audit Policies are configured again in the method "Configure Account Policies" in a much more reliable way, however I wanted to give users the potential to configure only the audit policy, without having to use a completely different security template, hence this solution.

###Configure Account Policies 
This method expects the file path of the security template to be "C:\HivestormTemplate.inf". This file name / path can be changed on line 99, in the $templatePath var. The logic behind this method is it takes a preconfigured security template, and then applies the premade template to machine running the script.

###Locate and Remove Media Files
I cant say this enough, .txt files are considered media files for the purposes of this script. This is to catch any users who may be storing passwords or other sensetive info in .txt files. This method will prompt for confirmation before removing any files, it *should* not find the forensic questions but I suggest using caution and read the confirmations before deleting a file. The best practice would be to follow the file path yourself to examine the file before confirming its removal. Always refer to the Hivestorm ReadMe to ensure the file your deleting is not needed in order to answer the Forensic Questions or some other reason. Finally, this method *only* identifies media files (including .txt) in the **Users** folder. This can be changed on line 126, although I do not recommend it.

###Disable Insecure Services
This will disable Remote Desktop Services by default, double check the ReadMe and use your critical thinking skills to ensure you are confident this will not be an issue. If you do not want this service to be disabled, remove "RemoteDesktopServices" from the var $servicesToDisable on line 178. This wont disable very many services, as I chose to air on the side of caution. You may manually enable/disable services at your discretion or add/remove services to the aforementioned variable.

###Run All Security Functions
Literally just runs the previous 4 functions in numerical order. This means the security template will apply after the audit policy has been configured, so run the audit policy after you run all **if** you want the Configure Audit Policies method to override the audit policies defined in the security template -- which once again I do not recommend.
