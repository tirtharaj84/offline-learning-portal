"""Portable engine tests with mocked Windows commands and disposable directories.
These do not exercise the Windows Forms UI or actual Windows services/firewall.
"""
import json, os, pathlib, shutil, subprocess, tempfile, unittest
ROOT = pathlib.Path(__file__).resolve().parents[1]
PWSH = os.environ.get('PORTAL_TEST_PWSH') or shutil.which('pwsh')

@unittest.skipUnless(PWSH and os.name != 'nt', 'requires PowerShell on a POSIX preparation host')
class UninstallEngineTests(unittest.TestCase):
    def run_case(self, delete=False, prompt='REMOVE', mismatch=None):
        with tempfile.TemporaryDirectory(prefix='portal-removal-test-') as tmp:
            sandbox=pathlib.Path(tmp); installed=sandbox/'installed'; runner=sandbox/'runner'
            (installed/'runtime/nginx').mkdir(parents=True); runner.mkdir()
            resource=installed/'school-resource.txt'; resource.write_text('keep this lesson')
            operations=sandbox/'operations.txt'; result=sandbox/'result.json'
            state={'install_directory':str(installed),'service_name':'TestPortal',
                   'nginx_application':str(installed/'runtime/nginx/nginx.exe'),
                   'firewall_names':['TestPortal-HTTP'],'status':'running'}
            if mismatch=='folder': state['install_directory']=str(sandbox/'somewhere-else')
            if mismatch=='rule': state['firewall_names']=['UnrelatedRule']
            (installed/'installation.json').write_text(json.dumps(state))
            fake=installed/'runtime/nssm.exe'
            fake.write_text('#!/bin/sh\nprintf "nssm-remove\\n" >> "$PORTAL_TEST_OPLOG"\nexit 0\n'); fake.chmod(0o700)
            # Remove only the administrative host requirement in the test copy.
            engine=(ROOT/'scripts/Uninstall-Portal.ps1').read_text().replace('#requires -RunAsAdministrator\n','')
            (runner/'Uninstall-Portal.ps1').write_text(engine)
            shutil.copyfile(ROOT/'scripts/Uninstall-Helpers.ps1',runner/'Uninstall-Helpers.ps1')
            mock=r'''
$script:serviceState='Running'
function Get-Service {param($Name,$ErrorAction)
 $o=[pscustomobject]@{Status=$script:serviceState}
 $o | Add-Member ScriptMethod WaitForStatus {param($Status,$Timeout)}
 return $o
}
function Get-ItemProperty {param($LiteralPath,$Name,$ErrorAction)
 return [pscustomobject]@{Application=$env:PORTAL_TEST_APP}
}
function Stop-Service {param($Name,$ErrorAction)
 if($Name -ne 'TestPortal'){throw 'Unexpected service'}
 $script:serviceState='Stopped';Add-Content -LiteralPath $env:PORTAL_TEST_OPLOG 'service-stop'
}
function Get-NetFirewallRule {param($Name,$ErrorAction);return [pscustomobject]@{Name=$Name}}
function Remove-NetFirewallRule {param([Parameter(ValueFromPipeline)]$InputObject)
 process{Add-Content -LiteralPath $env:PORTAL_TEST_OPLOG ('firewall-remove:'+ $InputObject.Name)}
}
function Read-Host {param($Prompt)
 if($Prompt -like 'Permanently*'){return $env:PORTAL_TEST_DELETE_PROMPT}
 return $env:PORTAL_TEST_PROMPT
}
. (Join-Path $PSScriptRoot 'Uninstall-Portal.ps1') -InstallRoot $env:PORTAL_TEST_ROOT -ResultPath $env:PORTAL_TEST_RESULT -DeleteFiles:([bool]::Parse($env:PORTAL_TEST_DELETE))
exit $LASTEXITCODE
'''
            script=runner/'mock-host.ps1';script.write_text(mock)
            env=os.environ.copy();env.update(PORTAL_TEST_ROOT=str(installed),PORTAL_TEST_RESULT=str(result),
                PORTAL_TEST_OPLOG=str(operations),PORTAL_TEST_APP=str(installed/'runtime/nginx/nginx.exe'),
                PORTAL_TEST_DELETE=str(delete),PORTAL_TEST_PROMPT=prompt,PORTAL_TEST_DELETE_PROMPT='DELETE' if prompt=='REMOVE' else 'NO')
            if mismatch=='service':env['PORTAL_TEST_APP']=str(sandbox/'another-app.exe')
            completed=subprocess.run([PWSH,'-NoProfile','-File',str(script)],env=env,capture_output=True,text=True,timeout=20)
            return {'code':completed.returncode,'output':completed.stdout+completed.stderr,
                    'exists':installed.exists(),'resource':resource.read_text() if resource.exists() else None,
                    'state':json.loads((installed/'installation.json').read_text()) if installed.exists() else None,
                    'ops':operations.read_text().splitlines() if operations.exists() else [],
                    'result':json.loads(result.read_text(encoding='utf-8-sig')) if result.exists() else None}
    def test_keep_preserves_files_and_removes_owned_service_rules(self):
        r=self.run_case();self.assertEqual(r['code'],0,r['output']);self.assertEqual(r['resource'],'keep this lesson')
        self.assertEqual(r['state']['status'],'uninstalled-files-preserved')
        self.assertEqual(r['ops'],['service-stop','nssm-remove','firewall-remove:TestPortal-HTTP'])
        self.assertFalse(r['result']['deleted'])
    def test_delete_removes_only_owned_directory_and_reports_success(self):
        r=self.run_case(delete=True);self.assertEqual(r['code'],0,r['output']);self.assertFalse(r['exists']);self.assertTrue(r['result']['deleted'])
    def test_cancel_does_not_mutate_installation(self):
        r=self.run_case(delete=True,prompt='NO');self.assertEqual(r['code'],0,r['output']);self.assertEqual(r['ops'],[])
        self.assertEqual(r['resource'],'keep this lesson');self.assertEqual(r['state']['status'],'running')
    def test_ownership_folder_mismatch_refuses_removal(self):
        r=self.run_case(delete=True,mismatch='folder');self.assertNotEqual(r['code'],0);self.assertEqual(r['ops'],[]);self.assertTrue(r['exists'])
    def test_other_service_application_refuses_removal(self):
        r=self.run_case(delete=True,mismatch='service');self.assertNotEqual(r['code'],0);self.assertEqual(r['ops'],[]);self.assertTrue(r['exists'])
    def test_unrelated_firewall_rule_refuses_removal(self):
        r=self.run_case(delete=True,mismatch='rule');self.assertNotEqual(r['code'],0);self.assertEqual(r['ops'],[]);self.assertTrue(r['exists'])

if __name__=='__main__': unittest.main()
