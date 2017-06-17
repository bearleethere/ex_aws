defmodule ExAws.EC2.ParserTest do
  use ExUnit.Case, async: true
  alias ExAws.EC2.Parsers

  test "parsing attach volume response" do
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


  test "parsing delete_volume_response" do
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

  def to_success(doc) do
    {:ok, %{body: doc}}
  end

  def to_error(doc) do
    {:error, {:http_error, 403, %{body: doc}}}
  end

  defp config(), do: ExAws.Config.new(:ec2, [])

  # test "parsing describe instances response" do
  #   resp = """
  #   <DescribeInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2016-11-15/">
  #     <requestId>8f7724cf-496f-496e-8fe3-example</requestId>
  #     <reservationSet>
  #       <item>
  #         <reservationId>r-1234567890abcdef0</reservationId>
  #         <ownerId>123456789012</ownerId>
  #         <groupSet/>
  #         <instancesSet>
  #           <item>
  #             <instanceId>i-1234567890abcdef0</instanceId>
  #             <imageId>ami-bff32ccc</imageId>
  #             <instanceState>
  #               <code>16</code>
  #               <name>running</name>
  #             </instanceState>
  #             <privateDnsName>ip-192-168-1-88.eu-west-1.compute.internal</privateDnsName>
  #             <dnsName>ec2-54-194-252-215.eu-west-1.compute.amazonaws.com</dnsName>
  #             <reason/>
  #             <keyName>my_keypair</keyName>
  #             <amiLaunchIndex>0</amiLaunchIndex>
  #             <productCodes/>
  #             <instanceType>t2.micro</instanceType>
  #             <launchTime>2015-12-22T10:44:05.000Z</launchTime>
  #             <placement>
  #               <availabilityZone>eu-west-1c</availabilityZone>
  #               <groupName/>
  #               <tenancy>default</tenancy>
  #             </placement>
  #             <monitoring>
  #               <state>disabled</state>
  #             </monitoring>
  #             <subnetId>subnet-56f5f633</subnetId>
  #             <vpcId>vpc-11112222</vpcId>
  #             <privateIpAddress>192.168.1.88</privateIpAddress>
  #             <ipAddress>54.194.252.215</ipAddress>
  #             <sourceDestCheck>true</sourceDestCheck>
  #             <groupSet>
  #               <item>
  #                 <groupId>sg-e4076980</groupId>
  #                 <groupName>SecurityGroup1</groupName>
  #               </item>
  #             </groupSet>
  #             <architecture>x86_64</architecture>
  #             <rootDeviceType>ebs</rootDeviceType>
  #             <rootDeviceName>/dev/xvda</rootDeviceName>
  #             <blockDeviceMapping>
  #               <item>
  #                 <deviceName>/dev/xvda</deviceName>
  #                 <ebs>
  #                   <volumeId>vol-1234567890abcdef0</volumeId>
  #                   <status>attached</status>
  #                   <attachTime>2015-12-22T10:44:09.000Z</attachTime>
  #                   <deleteOnTermination>true</deleteOnTermination>
  #                 </ebs>
  #               </item>
  #             </blockDeviceMapping>
  #             <virtualizationType>hvm</virtualizationType>
  #             <clientToken>xMcwG14507example</clientToken>
  #             <tagSet>
  #               <item>
  #                 <key>Name</key>
  #                 <value>Server_1</value>
  #               </item>
  #             </tagSet>
  #             <hypervisor>xen</hypervisor>
  #             <networkInterfaceSet>
  #               <item>
  #                 <networkInterfaceId>eni-551ba033</networkInterfaceId>
  #                 <subnetId>subnet-56f5f633</subnetId>
  #                 <vpcId>vpc-11112222</vpcId>
  #                 <description>Primary network interface</description>
  #                 <ownerId>123456789012</ownerId>
  #                 <status>in-use</status>
  #                 <macAddress>02:dd:2c:5e:01:69</macAddress>
  #                 <privateIpAddress>192.168.1.88</privateIpAddress>
  #                 <privateDnsName>ip-192-168-1-88.eu-west-1.compute.internal</privateDnsName>
  #                 <sourceDestCheck>true</sourceDestCheck>
  #                 <groupSet>
  #                   <item>
  #                     <groupId>sg-e4076980</groupId>
  #                     <groupName>SecurityGroup1</groupName>
  #                   </item>
  #                 </groupSet>
  #                 <attachment>
  #                   <attachmentId>eni-attach-39697adc</attachmentId>
  #                   <deviceIndex>0</deviceIndex>
  #                   <status>attached</status>
  #                   <attachTime>2015-12-22T10:44:05.000Z</attachTime>
  #                   <deleteOnTermination>true</deleteOnTermination>
  #                 </attachment>
  #                 <association>
  #                   <publicIp>54.194.252.215</publicIp>
  #                   <publicDnsName>ec2-54-194-252-215.eu-west-1.compute.amazonaws.com</publicDnsName>
  #                   <ipOwnerId>amazon</ipOwnerId>
  #                 </association>
  #                 <privateIpAddressesSet>
  #                   <item>
  #                     <privateIpAddress>192.168.1.88</privateIpAddress>
  #                     <privateDnsName>ip-192-168-1-88.eu-west-1.compute.internal</privateDnsName>
  #                     <primary>true</primary>
  #                     <association>
  #                       <publicIp>54.194.252.215</publicIp>
  #                       <publicDnsName>ec2-54-194-252-215.eu-west-1.compute.amazonaws.com</publicDnsName>
  #                       <ipOwnerId>amazon</ipOwnerId>
  #                     </association>
  #                   </item>
  #                 </privateIpAddressesSet>
  #                 <ipv6AddressesSet>
  #                   <item>
  #                     <ipv6Address>2001:db8:1234:1a2b::123</ipv6Address>
  #                   </item>
  #                 </ipv6AddressesSet>
  #               </item>
  #             </networkInterfaceSet>
  #             <ebsOptimized>false</ebsOptimized>
  #         </item>
  #       </instancesSet>
  #     </item>
  #   </reservationSet>
  # </DescribeInstancesResponse>
  # """
  # end

end
