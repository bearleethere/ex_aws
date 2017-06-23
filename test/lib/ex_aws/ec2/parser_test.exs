defmodule ExAws.EC2.ParserTest do
  use ExUnit.Case, async: true
  alias ExAws.EC2.Parsers

  def to_success(doc) do
    {:ok, %{body: doc}}
  end

  test "parsing describe instances response" do
    resp = """
    <DescribeInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>8f7724cf-496f-496e-8fe3-example</requestId>
      <reservationSet>
        <item>
          <reservationId>r-1234567890abcdef0</reservationId>
          <ownerId>123456789012</ownerId>
          <groupSet/>
          <instancesSet>
            <item>
              <instanceId>i-1234567890abcdef0</instanceId>
              <imageId>ami-bff32ccc</imageId>
              <instanceState>
                <code>16</code>
                <name>running</name>
              </instanceState>
              <privateDnsName>ip-192-168-1-88.eu-west-1.compute.internal</privateDnsName>
              <dnsName>ec2-54-194-252-215.eu-west-1.compute.amazonaws.com</dnsName>
              <reason/>
              <keyName>my_keypair</keyName>
              <amiLaunchIndex>0</amiLaunchIndex>
              <productCodes/>
              <instanceType>t2.micro</instanceType>
              <launchTime>2015-12-22T10:44:05.000Z</launchTime>
              <placement>
                <availabilityZone>eu-west-1c</availabilityZone>
                <groupName/>
                <tenancy>default</tenancy>
              </placement>
              <monitoring>
                <state>disabled</state>
              </monitoring>
              <subnetId>subnet-56f5f633</subnetId>
              <vpcId>vpc-11112222</vpcId>
              <privateIpAddress>192.168.1.88</privateIpAddress>
              <ipAddress>54.194.252.215</ipAddress>
              <sourceDestCheck>true</sourceDestCheck>
              <groupSet>
                <item>
                  <groupId>sg-e4076980</groupId>
                  <groupName>SecurityGroup1</groupName>
                </item>
              </groupSet>
              <architecture>x86_64</architecture>
              <rootDeviceType>ebs</rootDeviceType>
              <rootDeviceName>/dev/xvda</rootDeviceName>
              <blockDeviceMapping>
                <item>
                  <deviceName>/dev/xvda</deviceName>
                  <ebs>
                    <volumeId>vol-1234567890abcdef0</volumeId>
                    <status>attached</status>
                    <attachTime>2015-12-22T10:44:09.000Z</attachTime>
                    <deleteOnTermination>true</deleteOnTermination>
                  </ebs>
                </item>
              </blockDeviceMapping>
              <virtualizationType>hvm</virtualizationType>
              <clientToken>xMcwG14507example</clientToken>
              <tagSet>
                <item>
                  <key>Name</key>
                  <value>Server_1</value>
                </item>
              </tagSet>
              <hypervisor>xen</hypervisor>
              <networkInterfaceSet>
                <item>
                  <networkInterfaceId>eni-551ba033</networkInterfaceId>
                  <subnetId>subnet-56f5f633</subnetId>
                  <vpcId>vpc-11112222</vpcId>
                  <description>Primary network interface</description>
                  <ownerId>123456789012</ownerId>
                  <status>in-use</status>
                  <macAddress>02:dd:2c:5e:01:69</macAddress>
                  <privateIpAddress>192.168.1.88</privateIpAddress>
                  <privateDnsName>ip-192-168-1-88.eu-west-1.compute.internal</privateDnsName>
                  <sourceDestCheck>true</sourceDestCheck>
                  <groupSet>
                    <item>
                      <groupId>sg-e4076980</groupId>
                      <groupName>SecurityGroup1</groupName>
                    </item>
                  </groupSet>
                  <attachment>
                    <attachmentId>eni-attach-39697adc</attachmentId>
                    <deviceIndex>0</deviceIndex>
                    <status>attached</status>
                    <attachTime>2015-12-22T10:44:05.000Z</attachTime>
                    <deleteOnTermination>true</deleteOnTermination>
                  </attachment>
                  <association>
                    <publicIp>54.194.252.215</publicIp>
                    <publicDnsName>ec2-54-194-252-215.eu-west-1.compute.amazonaws.com</publicDnsName>
                    <ipOwnerId>amazon</ipOwnerId>
                  </association>
                  <privateIpAddressesSet>
                    <item>
                      <privateIpAddress>192.168.1.88</privateIpAddress>
                      <privateDnsName>ip-192-168-1-88.eu-west-1.compute.internal</privateDnsName>
                      <primary>true</primary>
                      <association>
                        <publicIp>54.194.252.215</publicIp>
                        <publicDnsName>ec2-54-194-252-215.eu-west-1.compute.amazonaws.com</publicDnsName>
                        <ipOwnerId>amazon</ipOwnerId>
                      </association>
                    </item>
                  </privateIpAddressesSet>
                  <ipv6AddressesSet>
                    <item>
                      <ipv6Address>2001:db8:1234:1a2b::123</ipv6Address>
                    </item>
                  </ipv6AddressesSet>
                </item>
              </networkInterfaceSet>
              <ebsOptimized>false</ebsOptimized>
            </item>
          </instancesSet>
        </item>
      </reservationSet>
    </DescribeInstancesResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :describe_instances, nil)
    assert parsed_doc[:request_id] == "8f7724cf-496f-496e-8fe3-example"
    assert parsed_doc[:reservations] |> length == 1

    reservation = List.first(parsed_doc[:reservations])
    instance = List.first(reservation[:instances])

    assert instance[:instance_id] == "i-1234567890abcdef0"

    instance_state = instance[:state]
    assert instance_state[:code] == "16"

    block_device_mappings = instance[:block_device_mapping]
    bdm = List.first(block_device_mappings)
    assert bdm[:device_name] == "/dev/xvda"

    ebs = bdm[:ebs]
    assert ebs[:volume_id] == "vol-1234567890abcdef0"
    assert ebs[:status] == "attached"
  end

  test "parsing describe_instance_status response" do
    resp = """
    <DescribeInstanceStatusResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>3be1508e-c444-4fef-89cc-0b1223c4f02fEXAMPLE</requestId>
      <instanceStatusSet>
        <item>
          <instanceId>i-1234567890abcdef0</instanceId>
          <availabilityZone>us-east-1d</availabilityZone>
          <instanceState>
            <code>16</code>
            <name>running</name>
          </instanceState>
          <systemStatus>
            <status>impaired</status>
            <details>
              <item>
                <name>reachability</name>
                <status>failed</status>
                <impairedSince>YYYY-MM-DDTHH:MM:SS.000Z</impairedSince>
              </item>
            </details>
          </systemStatus>
          <instanceStatus>
            <status>impaired</status>
            <details>
              <item>
                <name>reachability</name>
                <status>failed</status>
                <impairedSince>YYYY-MM-DDTHH:MM:SS.000Z</impairedSince>
              </item>
            </details>
          </instanceStatus>
          <eventsSet>
            <item>
              <code>instance-retirement</code>
              <description>The instance is running on degraded hardware</description>
              <notBefore>YYYY-MM-DDTHH:MM:SS+0000</notBefore>
              <notAfter>YYYY-MM-DDTHH:MM:SS+0000</notAfter>
            </item>
          </eventsSet>
        </item>
      </instanceStatusSet>
    </DescribeInstanceStatusResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :describe_instance_status, nil)
    assert parsed_doc[:instances_statuses] |> length == 1

    instance_status = List.first(parsed_doc[:instances_statuses])
    assert instance_status[:instance_id] == "i-1234567890abcdef0"
    assert instance_status[:availability_zone] == "us-east-1d"

    system_status = instance_status[:system_status]
    assert system_status[:status] == "impaired"

    system_status_detail = List.first(system_status[:details])
    assert system_status_detail[:name] ==  "reachability"
    assert system_status_detail[:status] == "failed"

    event = List.first(instance_status[:events])
    assert event[:code] == "instance-retirement"
    assert event[:description] == "The instance is running on degraded hardware"
  end

  test "parsing terminate_instances response" do
    resp = """
    <TerminateInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <instancesSet>
        <item>
          <instanceId>i-1234567890abcdef0</instanceId>
          <currentState>
            <code>32</code>
            <name>shutting-down</name>
          </currentState>
          <previousState>
            <code>16</code>
            <name>running</name>
          </previousState>
        </item>
      </instancesSet>
    </TerminateInstancesResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :terminate_instances, nil)
    instance = List.first(parsed_doc[:instances])
    assert instance[:instance_id] == "i-1234567890abcdef0"

    current_state = instance[:current_state]
    assert current_state[:code] == "32"
    assert current_state[:name] == "shutting-down"

  end

  test "parsing reboot_instances response" do
    resp = """
    <RebootInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <return>true</return>
    </RebootInstancesResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :reboot_instances, nil)
    assert parsed_doc[:return] == "true"
    assert parsed_doc[:request_id] == "59dbff89-35bd-4eac-99ed-be587EXAMPLE"
  end

  test "parsing start_instances response" do
    resp = """
    <StartInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <instancesSet>
        <item>
          <instanceId>i-1234567890abcdef0</instanceId>
          <currentState>
            <code>0</code>
            <name>pending</name>
          </currentState>
          <previousState>
            <code>80</code>
            <name>stopped</name>
          </previousState>
        </item>
      </instancesSet>
    </StartInstancesResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :start_instances, nil)
    instance = List.first(parsed_doc[:instances])
    assert instance[:instance_id] == "i-1234567890abcdef0"

    current_state = instance[:current_state]
    assert current_state[:code] == "0"
    assert current_state[:name] == "pending"

    previous_state = instance[:previous_state]
    assert previous_state[:code] == "80"
    assert previous_state[:name] == "stopped"
  end

  test "parsing stop_instances response" do
    resp = """
    <StopInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <instancesSet>
        <item>
          <instanceId>i-1234567890abcdef0</instanceId>
          <currentState>
            <code>64</code>
            <name>stopping</name>
          </currentState>
          <previousState>
            <code>16</code>
            <name>running</name>
          </previousState>
        </item>
      </instancesSet>
    </StopInstancesResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :stop_instances, nil)
    instance = List.first(parsed_doc[:instances])
    assert instance[:instance_id] == "i-1234567890abcdef0"

    current_state = instance[:current_state]
    assert current_state[:code] == "64"
    assert current_state[:name] == "stopping"

    previous_state = instance[:previous_state]
    assert previous_state[:code] == "16"
    assert previous_state[:name] == "running"
  end


  test "parsing attach_volume response" do
    resp = """
    <AttachVolumeResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <volumeId>vol-1234567890abcdef0</volumeId>
      <instanceId>i-1234567890abcdef0</instanceId>
      <device>/dev/sdh</device>
      <status>attaching</status>
      <attachTime>YYYY-MM-DDTHH:MM:SS.000Z</attachTime>
    </AttachVolumeResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :attach_volume, nil)
    assert parsed_doc[:volume_id] == "vol-1234567890abcdef0"
    assert parsed_doc[:instance_id] == "i-1234567890abcdef0"
    assert parsed_doc[:device] == "/dev/sdh"
    assert parsed_doc[:status] == "attaching"
  end

  test "parsing detach volume response" do
    resp = """
    <DetachVolumeResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <volumeId>vol-1234567890abcdef0</volumeId>
      <instanceId>i-1234567890abcdef0</instanceId>
      <device>/dev/sdh</device>
      <status>detaching</status>
      <attachTime>YYYY-MM-DDTHH:MM:SS.000Z</attachTime>
    </DetachVolumeResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :detach_volume, nil)
    assert parsed_doc[:volume_id] == "vol-1234567890abcdef0"
    assert parsed_doc[:instance_id] == "i-1234567890abcdef0"
    assert parsed_doc[:device] == "/dev/sdh"
    assert parsed_doc[:status] == "detaching"
  end

  test "parsing create_volume response" do
    resp = """
    <CreateVolumeResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <volumeId>vol-1234567890abcdef0</volumeId>
      <size>80</size>
      <snapshotId/>
      <availabilityZone>us-east-1a</availabilityZone>
      <status>creating</status>
      <createTime>YYYY-MM-DDTHH:MM:SS.000Z</createTime>
      <volumeType>standard</volumeType>
      <encrypted>true</encrypted>
    </CreateVolumeResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :create_volume, nil)
    assert parsed_doc[:volume_id] == "vol-1234567890abcdef0"
    assert parsed_doc[:size] == "80"
    assert parsed_doc[:availability_zone] == "us-east-1a"
    assert parsed_doc[:status] == "creating"
    assert parsed_doc[:volume_type] == "standard"
  end


  test "parsing delete_volume response" do
    resp = """
    <DeleteVolumeResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
      <return>true</return>
    </DeleteVolumeResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :delete_volume, nil)
    assert parsed_doc[:return] == "true" # WTF >_< Seriously "return"? Of all of the names they could have came up with...
  end


  test "parsing modify_volume response" do
    resp = """
    <ModifyVolumeResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
      <requestId>5jkdf074-37ed-4004-8671-a78ee82bf1cbEXAMPLE</requestId>
      <volumeModification>
        <targetIops>10000</targetIops>
        <originalIops>300</originalIops>
        <modificationState>modifying</modificationState>
        <targetSize>200</targetSize>
        <targetVolumeType>io1</targetVolumeType>
        <volumeId>vol-1234567890EXAMPLE</volumeId>
        <progress>0</progress>
        <startTime>2017-01-19T23:58:04.922Z</startTime>
        <originalSize>100</originalSize>
        <originalVolumeType>gp2</originalVolumeType>
      </volumeModification>
    </ModifyVolumeResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(resp, :modify_volume, nil)
    assert parsed_doc[:target_iops] == "10000"
    assert parsed_doc[:original_iops] == "300"
    assert parsed_doc[:modification_state] == "modifying"
    assert parsed_doc[:target_size] == "200"
    assert parsed_doc[:progress] == "0"
    assert parsed_doc[:target_volume_type] == "io1"
    assert parsed_doc[:original_size] == "100"
  end


  test "parsing error" do
    resp = """
    <Response>
      <Errors>
        <Error>
          <Code>VolumeInUse</Code>
          <Message>vol-0d64915304625f48d is already attached to an instance</Message>
        </Error>
      </Errors>
      <RequestID>4e0d9496-ab4b-495a-ba75-f895aa0d8634</RequestID>
    </Response>
    """
    |> to_error

    {:error, {:http_error, 403, error}} = Parsers.parse(resp, :attach_volume, config())
    assert error[:code] == "VolumeInUse"
    assert error[:message] == "vol-0d64915304625f48d is already attached to an instance"
  end

  def to_error(doc) do
    {:error, {:http_error, 403, %{body: doc}}}
  end

  defp config(), do: ExAws.Config.new(:ec2, [])

end
