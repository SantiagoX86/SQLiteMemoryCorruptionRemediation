# VulnerabilityManagement
Vulnerability Management project in which I used the Tenable Vulnerability Management platform to scan VM on an Azure Network, applied pre-built remediation scripts in Powershell, and developed/applied additional scripts to remediate remaining vulnerabilitie

---


<img width="1000" alt="image" src="https://github.com/user-attachments/assets/cfc5dbcf-3fcb-4a71-9c13-2a49f8bab3e6">

# Technology Utilized
- Tenable (enterprise vulnerability management platform)
- Azure Virtual Machines (Nessus scan engine + scan targets)
- PowerShell & BASH (remediation scripts)

---


# Table of Contents

- [VulnerabilityManagement](#vulnerabilitymanagement)
- [Technology Utilized](#technology-utilized)
- [Table of Contents](#table-of-contents)
    - [Initial Vulnerability Scan of Azure VM LogNPacific3286](#initial-vulnerability-scan-of-azure-vm-lognpacific3286)
    - [Traige and Prioritization](#traige-and-prioritization)
    - [Stakeholder Consultation](#stakeholder-consultation)
    - [Application of Pre-built Remediation Scripts](#application-of-pre-built-remediation-scripts)
    - [Secondary Scan Following Application of Remediation Scripts](#secondary-scan-following-application-of-remediation-scripts)
    - [Step 4) Mock Meeting: Initial Scan Permission (Server Team)](#step-4-mock-meeting-initial-scan-permission-server-team)
    - [Step 5) Initial Scan of Server Team Assets](#step-5-initial-scan-of-server-team-assets)
    - [Step 6) Vulnerability Assessment and Prioritization](#step-6-vulnerability-assessment-and-prioritization)
    - [Step 7) Distributing Remediations to Remediation Teams](#step-7-distributing-remediations-to-remediation-teams)
    - [Step 8) Mock Meeting: Post-Initial Discovery Scan (Server Team)](#step-8-mock-meeting-post-initial-discovery-scan-server-team)
    - [Step 9) Mock CAB Meeting: Implementing Remediations](#step-9-mock-cab-meeting-implementing-remediations)
    - [Step 10 ) Remediation Effort](#step-10--remediation-effort)
      - [Remediation Round 1: Outdated Wireshark Removal](#remediation-round-1-outdated-wireshark-removal)
      - [Remediation Round 2: Insecure Protocols \& Ciphers](#remediation-round-2-insecure-protocols--ciphers)
      - [Remediation Round 3: Guest Account Group Membership](#remediation-round-3-guest-account-group-membership)
      - [Remediation Round 4: Windows OS Updates](#remediation-round-4-windows-os-updates)
    - [First Cycle Remediation Effort Summary](#first-cycle-remediation-effort-summary)
    - [On-going Vulnerability Management (Maintenance Mode)](#on-going-vulnerability-management-maintenance-mode)

---

### Initial Vulnerability Scan of Azure VM LogNPacific3286

In this phase the initial scan was conducted and vulnerabilities were identified and prioritized. Existing related remediation scripts were identified for patch application via powershell execution.

---

### Traige and Prioritization

This stage consisted of analyzing vulnerabilities in terms of criticality using Tenable platform, assets affected, and ease of remediation based on existence of remediation script as opposed to those for which a script would need to be developed.

---

### Stakeholder Consultation

Stakeholders identified, notified of vulnerabilities, consulted on related assets, notified of identified patches to be implemented, and informed of which vulnerabilities would require patch development.

---

### Application of Pre-built Remediation Scripts

After consultation with stakeholders, this step was a role out of applications of the various scripts that had been identified in the previous phase to automate vulnerability remediation in a way that would be easily applicable at scale. Remediation application will vary by vulnerability based on information gathers in Triage and Stakeholder consultation. Significant remediation script application would ideally be conducted in stages as follows:
- Sandbox stage role out in a synthetic environment
- Small scale role out on minimal number of least critical assets
- Small scale role out on minimal number of assets of all criticality levels
- Full scale role out on all vulnerable assets

---

### Secondary Scan Following Application of Remediation Scripts

Finish this section next

---

### Step 4) Mock Meeting: Initial Scan Permission (Server Team)

The team collaborates with the server team to initiate scheduled credential scans. A compromise is reached to scan a single server first, monitoring resource impact, and using just-in-time Active Directory credentials for secure, controlled access.  

<a href='https://youtu.be/lg068WA4SKM' target="_"><img width="600" alt="image" src="https://github.com/user-attachments/assets/31fe8d0f-636b-475b-8d5a-a2795c183f86"></a>

[YouTube Video: Initial Discovery Scan](https://youtu.be/lg068WA4SKM)

---

### Step 5) Initial Scan of Server Team Assets

In this phase, an insecure Windows Server is provisioned to simulate the server team's environment. After creating vulnerabilities, an authenticated scan is performed, and the results are exported for future remediation steps.  

<img width="635" alt="image" src="https://github.com/user-attachments/assets/937cccbd-36bb-4445-97b9-e915085cda81" style="border: 2px solid black;">

[Scan 1 - Initial Scan](https://drive.google.com/file/d/1RBPVj_azKJMwmRZ8QILlb4hxIjQU3wQ7/view?usp=drive_link)




---

### Step 6) Vulnerability Assessment and Prioritization

We assessed vulnerabilities and established a remediation prioritization strategy based on ease of remediation and impact. The following priorities were set:

1. Third Party Software Removal (Wireshark)
2. Windows OS Secure Configuration (Protocols & Ciphers)
3. Windows OS Secure Configuration (Guest Account Group Membership)
4. Windows OS Updates

---

### Step 7) Distributing Remediations to Remediation Teams

The server team received remediation scripts and scan reports to address key vulnerabilities. This streamlined their efforts and prepared them for a follow-up review.  

<img width="635" alt="image" src="https://github.com/user-attachments/assets/bbf9478f-e1d1-4898-846e-b510ec8c6f72">

[Remediation Email](https://github.com/joshmadakor1/lognpacific-public/blob/main/misc/remediation-email.md)

---

### Step 8) Mock Meeting: Post-Initial Discovery Scan (Server Team)

The server team reviewed vulnerability scan results, identifying outdated software, insecure accounts, and deprecated protocols. The remediation packages were prepared for submission to the Change Control Board (CAB). 

<a href="https://youtu.be/0tjjFewxSNw" target="_"><img width="600" src="https://github.com/user-attachments/assets/03027c66-5f7c-42d0-b6dd-09d053c040b1"/></a>

[Meeting Video](https://youtu.be/0tjjFewxSNw)

---

### Step 9) Mock CAB Meeting: Implementing Remediations

The Change Control Board (CAB) reviewed and approved the plan to remove insecure protocols and cipher suites. The plan included a rollback script and a tiered deployment approach.  

<a href="https://youtu.be/zOFPkTa9kY8" target="_"><img width="600" src="https://github.com/user-attachments/assets/07164e63-fbce-471a-b469-29a6d41b7bb8"/></a>

[Meeting Video](https://youtu.be/zOFPkTa9kY8)

---
### Step 10 ) Remediation Effort

#### Remediation Round 1: Outdated Wireshark Removal

The server team used a PowerShell script to remove outdated Wireshark. A follow-up scan confirmed successful remediation.  
[Wireshark Removal Script](https://github.com/joshmadakor1/lognpacific-public/blob/main/automation/remediation-wireshark-uninstall.ps1)  

<img width="634" alt="image" src="https://github.com/user-attachments/assets/7b4f9ab2-d230-4458-ac0f-c0ff070ae79a">

[Scan 2 - Third Party Software Removal](https://drive.google.com/file/d/1UiwPPTtuSZKk02hiMyXf31pXUIeC5EWt/view?usp=drive_link)


#### Remediation Round 2: Insecure Protocols & Ciphers

The server team used PowerShell scripts to remediate insecure protocols and cipher suites. A follow-up scan verified successful remediation, and the results were saved for reference.  
[PowerShell: Insecure Protocols Remediation](https://github.com/joshmadakor1/lognpacific-public/blob/main/automation/toggle-protocols.ps1)
[PowerShell: Insecure Ciphers Remediation](https://github.com/joshmadakor1/lognpacific-public/blob/main/automation/toggle-cipher-suites.ps1)

<img width="630" alt="image" src="https://github.com/user-attachments/assets/0e96120d-8ec9-4f76-8e42-79c752200010">

[Scan 3 - Ciphersuites and Protocols](https://drive.google.com/file/d/1Qc6-ezQvwReCGUZNtnva0kCZo_-zW-Sm/view?usp=drive_link)


#### Remediation Round 3: Guest Account Group Membership

The server team removed the guest account from the administrator group. A new scan confirmed remediation, and the results were exported for comparison.  
[PowerShell: Guest Account Group Membership Remediation](https://github.com/joshmadakor1/lognpacific-public/blob/main/automation/toggle-guest-local-administrators.ps1)  

<img width="627" alt="image" src="https://github.com/user-attachments/assets/870a3eac-3398-44fe-91c0-96f3c2578df4">

[Scan 4 - Guest Account Group Removal](https://drive.google.com/file/d/1jVgikjfrV1YjOcL3QRT_oUB0Y82w22V7/view?usp=drive_link)


#### Remediation Round 4: Windows OS Updates

Windows updates were re-enabled and applied until the system was fully up to date. A final scan verified the changes  

<img width="627" alt="image" src="https://github.com/user-attachments/assets/870a3eac-3398-44fe-91c0-96f3c2578df4">

[Scan 5 - Post Windows Updates](https://drive.google.com/file/d/1tmDjeHl5uiGitRwWy8kFRi33q-nGi1Zt/view?usp=drive_link)

---

### First Cycle Remediation Effort Summary

The remediation process reduced total vulnerabilities by 80%, from 30 to 6. Critical vulnerabilities were resolved by the second scan (100%), and high vulnerabilities dropped by 90%. Mediums were reduced by 76%. In an actual production environment, asset criticality would further guide future remediation efforts.  

<img width="1920" alt="image" src="https://github.com/user-attachments/assets/51f0aae8-7f36-4d90-b29f-5257e57155f9">

[Remediation Data](https://docs.google.com/spreadsheets/d/1FTtFfZYmFsNLU6pm8nTzsKyKE-d2ftXzX_DPwcnFNfA/edit?gid=0#gid=0)

---

### On-going Vulnerability Management (Maintenance Mode)

After completing the initial remediation cycle, the vulnerability management program transitions into **Maintenance Mode**. This phase ensures that vulnerabilities continue to be managed proactively, keeping systems secure over time. Regular scans, continuous monitoring, and timely remediation are crucial components of this phase. (See [Finalized Policy](https://docs.google.com/document/d/1rvueLX_71pOR8ldN9zVW9r_zLzDQxVsnSUtNar8ftdg/edit?usp=drive_link) for scanning and remediation cadence requirements.)

Key activities in Maintenance Mode include:
- **Scheduled Vulnerability Scans**: Perform regular scans (e.g., weekly or monthly) to detect new vulnerabilities as systems evolve.
- **Patch Management**: Continuously apply security patches and updates, ensuring no critical vulnerabilities remain unpatched.
- **Remediation Follow-ups**: Address newly identified vulnerabilities promptly, prioritizing based on risk and impact.
- **Policy Review and Updates**: Periodically review the Vulnerability Management Policy to ensure it aligns with the latest security best practices and organizational needs.
- **Audit and Compliance**: Conduct internal audits to ensure compliance with the vulnerability management policy and external regulations.
- **Ongoing Communication with Stakeholders**: Maintain open communication with teams responsible for remediation, ensuring efficient coordination.

By maintaining an active vulnerability management process, organizations can stay ahead of emerging threats and ensure long-term security resilience.
