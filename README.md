# Automating-Weather-data-Upload-on-AWS
This project focuses on creating a Python application to fetch real-time weather data from the OpenWeather API and securely upload it to an AWS S3 bucket. It demonstrates how to integrate cloud services with Python applications, emphasizing the importance of maintaining clean environments using virtual environments.


## AWS Architecture Diagram illustrating the flow of file uploads
<img align="right" alt="AWS Diagram" src="https://miro.medium.com/v2/resize:fit:4800/format:webp/1*lmT8teKpjB77F4-IFD7BHA.png">

# Walkthrough 
<p>Read this detailed guide on fetching and storing real-time OpenWeather data in AWS S3:</p>
    <a href="https://medium.com/@goodycyb/terraform-deployment-to-fetch-and-store-real-time-open-weather-data-in-aws-s3-️-️-️-43f6236e16e2">
        Terraform Deployment to Fetch and Store Real-Time OpenWeather Data in AWS S3
    </a>
<hr/>

# How to execute the Terraform code
- Download or Clone the Files locally into a folder
- Open the Folder with a Code Editor e.g VScode
- Execute the <a href="https://medium.com/@goodycyb/terraform-deployment-to-fetch-and-store-real-time-open-weather-data-in-aws-s3-️-️-️-43f6236e16e2"> Terraform code </a>
- Delete once done using "Terraform Destroy"


## Terraform Execution Flow
  <strong>Networking:</strong> Configures a VPC, public subnet, and internet gateway for connectivity.
  <li><strong>Networking:</strong> Configures a VPC, public subnet, and internet gateway for connectivity.</li>
  <li><strong>Security:</strong> Sets up SSH access and allows outbound traffic through a security group.</li>
  <li><strong>S3 Storage:</strong> Creates a uniquely named S3 bucket with versioning enabled for weather data storage.</li>
  <li><strong>IAM Setup:</strong> Assigns an IAM role with a policy granting EC2 permissions to access the S3 bucket.</li>
  <li><strong>Instance Creation:</strong> Launches an EC2 instance configured with the security group and IAM role.</li>
  <li><strong>Provisioning:</strong> Deploys the Python script and <code>requirements.txt</code> file to the instance and prepares the runtime environment.</li>
  <li><strong>Key Management:</strong> Dynamically generates an SSH key pair (<code>.pem</code> file) for Linux and saves the private key locally for secure access.</li>

<br/>

# Deployment
<img align="right" alt="AWS Diagram" src="https://miro.medium.com/v2/resize:fit:1100/format:webp/1*Q3b7fSj6nbQhrixjW0nHQw.png">


<hr/>

# Upload
<img align="right" alt="AWS Diagram" src="https://miro.medium.com/v2/resize:fit:4800/format:webp/1*ESvWIH_2b6Sj75FPdoChZQ.png">
<br/> 


# Automation
<img align="right" alt="AWS Diagram" src="https://miro.medium.com/v2/resize:fit:1100/format:webp/1*dgURoY2bCb873ICPEcxnUg.png">
<img align="right" alt="AWS Diagram" src="https://miro.medium.com/v2/resize:fit:1100/format:webp/1*qHp_zeUpVypl05cF16zPpA.png">


