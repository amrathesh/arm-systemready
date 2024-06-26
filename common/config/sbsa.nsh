# Copyright (c) 2021-2023, ARM Limited and Contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of ARM nor the names of its contributors may be used
# to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

echo -off
for %i in 0 1 2 3 4 5 6 7 8 9 A B C D E F then
    if exist FS%i:\acs_results then
        FS%i:
        cd FS%i:\acs_results
        if not exist uefi then
            mkdir uefi
        endif
        cd uefi
        if not exist temp then
            mkdir temp
        endif
        #BSA_VERSION_PRINT_PLACEHOLDER
        if exist FS%i:\EFI\BOOT\bsa\Bsa.efi then
            echo "Press any key to start BSA in verbose mode."
            echo "If no key is pressed then BSA will be run in normal mode"
            FS%i:\EFI\BOOT\bbr\SCT\stallforkey.efi 10
            if %lasterror% == 0 then
                if exist FS%i:\acs_results\uefi\BsaVerboseResults.log then
                    echo "BSA ACS in verbose mode is already run."
                    echo "Press any key to start BSA ACS execution from the beginning."
                    echo "WARNING: Ensure you have backed up the existing logs."
                    FS%i:\EFI\BOOT\bbr\SCT\stallforkey.efi 10
                    if %lasterror% == 0 then
                        #Backup the existing logs
                        rm -q FS%i:\acs_results\uefi\BsaVerboseResults_previous_run.log
                        cp -r FS%i:\acs_results\uefi\BsaVerboseResults.log FS%i:\acs_results\uefi\BsaVerboseResults_previous_run.log
                        rm -q FS%i:\acs_results\uefi\BsaVerboseResults.log
                        goto BsaVerboseRun
                    endif
                    goto BsaNormalRun
                endif
:BsaVerboseRun
                echo "Running BSA in verbose mode"
                FS%i:\EFI\BOOT\bsa\Bsa.efi -v 1 -sbsa -skip 900 -f BsaVerboseTempResults.log
                stall 200000
                if exist FS%i:\acs_results\uefi\BsaVerboseTempResults.log then
                    echo " SystemReady SR ACS v2.1.0" > BsaVerboseResults.log
                    stall 200000
                    type BsaVerboseTempResults.log >> BsaVerboseResults.log
                    cp BsaVerboseTempResults.log temp/
                    rm BsaVerboseTempResults.log
                    reset
                else
                    echo "There may be issues in writing of BSA Verbose logs. Please save the console output"
                    reset
                endif
            endif
:BsaNormalRun
            if exist FS%i:\acs_results\uefi\BsaResults.log then
                echo "BSA ACS is already run."
                echo "Press any key to start BSA ACS execution from the beginning."
                echo "WARNING: Ensure you have backed up the existing logs."
                FS%i:\EFI\BOOT\bbr\SCT\stallforkey.efi 10
                if %lasterror% == 0 then
                    #Backup the existing logs
                    rm -q FS%i:\acs_results\uefi\BsaResults_previous_run.log
                    cp -r FS%i:\acs_results\uefi\BsaResults.log FS%i:\acs_results\uefi\BsaResults_previous_run.log
                    rm -q FS%i:\acs_results\uefi\BsaResults.log
                    goto BsaRun
                endif
                goto SbsaRun
            endif
:BsaRun
            FS%i:\EFI\BOOT\bsa\Bsa.efi -sbsa -skip 900 -f BsaTempResults.log
            stall 200000
            if exist FS%i:\acs_results\uefi\BsaTempResults.log then
                echo " SystemReady SR ACS v2.1.0" > BsaResults.log
                stall 200000
                type BsaTempResults.log >> BsaResults.log
                cp BsaTempResults.log temp/
                rm BsaTempResults.log
                reset
            else
                echo "There may be issues in writing of BSA logs. Please save the console output"
                reset
            endif
        else
            echo "Bsa.efi not present"
        endif
:SbsaRun
        if exist FS%i:\EFI\BOOT\bsa\sbsa\Sbsa.efi then
            echo Press any key to start SBSA in verbose mode. If no key is pressed then SBSA will be run in normal mode
            FS%i:\EFI\BOOT\bbr\SCT\stallforkey.efi 10
            if %lasterror% == 0 then
                if exist FS%i:\acs_results\uefi\SbsaVerboseResults.log then
                    echo "SBSA ACS in verbose mode is already run."
                    echo "Press any key to start SBSA ACS execution from the beginning."
                    echo "WARNING: Ensure you have backed up the existing logs."
                    FS%i:\EFI\BOOT\bbr\SCT\stallforkey.efi 10
                    if %lasterror% == 0 then
                        #Backup the existing logs
                        rm -q FS%i:\acs_results\uefi\SbsaVerboseResults_previous_run.log
                        cp -r FS%i:\acs_results\uefi\SbsaVerboseResults.log FS%i:\acs_results\uefi\SbsaVerboseResults_previous_run.log
                        rm -q FS%i:\acs_results\uefi\SbsaVerboseResults.log
                        goto SbsaVerboseRun
                    endif
                    goto SbsaNormalMode
                endif
:SbsaVerboseRun
                echo "Running SBSA in verbose mode"
                FS%i:\EFI\BOOT\bsa\sbsa\Sbsa.efi -v 1 -skip 900 -f SbsaVerboseTempResults.log
                stall 200000
                if exist FS%i:\acs_results\uefi\SbsaVerboseTempResults.log then
                    echo " SystemReady SR ACS v2.1.0" > SbsaVerboseResults.log
                    stall 200000
                    type SbsaVerboseTempResults.log >> SbsaVerboseResults.log
                    cp SbsaVerboseTempResults.log temp/
                    rm SbsaVerboseTempResults.log
                    reset
                else
                    echo "There may be issues in writing of SBSA Verbose logs. Please save the console output"
                    reset
                endif
            endif
:SbsaNormalMode
            if exist FS%i:\acs_results\uefi\SbsaResults.log then
                echo "SBSA ACS is already run."
                echo "Press any key to start SBSA ACS execution from the beginning."
                echo "WARNING: Ensure you have backed up the existing logs."
                FS%i:\EFI\BOOT\bbr\SCT\stallforkey.efi 10
                if %lasterror% == 0 then
                    #Backup the existing logs
                    rm -q FS%i:\acs_results\uefi\SbsaResults_previous_run.log
                    cp -r FS%i:\acs_results\uefi\SbsaResults.log FS%i:\acs_results\uefi\SbsaResults_previous_run.log
                    rm -q FS%i:\acs_results\uefi\SbsaResults.log
                    goto SbsaNormalRun
                endif
                goto Done
            endif
:SbsaNormalRun
            FS%i:\EFI\BOOT\bsa\sbsa\Sbsa.efi -skip 900 -f SbsaTempResults.log
            stall 200000
            if exist FS%i:\acs_results\uefi\SbsaTempResults.log then
                echo " SystemReady SR ACS v2.1.0" > SbsaResults.log
                stall 200000
                type SbsaTempResults.log >> SbsaResults.log
                cp SbsaTempResults.log temp/
                rm SbsaTempResults.log
                reset
            else
                echo "There may be issues in writing of SBSA logs. Please save the console output"
                reset
            endif
        else
            echo "Sbsa.efi not present"
        endif
        goto Done
    endif
endfor
echo "acs_results not found"
:Done
