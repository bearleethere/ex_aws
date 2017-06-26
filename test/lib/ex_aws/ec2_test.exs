defmodule ExAws.EC2Test do
  use ExUnit.Case, async: true
  alias ExAws.EC2
  alias ExAws.Operation.RestQuery

  @version "2015-10-01"

  defp build_query(http_method, action, params \\ %{}) do
    action_param = action |> Atom.to_string |> Macro.camelize

    %RestQuery{
      http_method: http_method,
      params: params |> Map.merge(%{"Version" => @version, "Action" => action_param}),
      path: "/",
      service: :ec2,
      action: action,
      parser: &ExAws.EC2.Parsers.parse/3
    }
  end

  ###################
  # Instances Tests #
  ###################
  test "describe_instances no additional params" do
    expected = build_query(:get, :describe_instances, %{})
    assert expected == EC2.describe_instances
  end

  test "describe_instances with filters and instance Ids" do
    expected = build_query(:get, :describe_instances, %{
      "Filter.1.Name" => "tag",
      "Filter.1.Value.1" => "Owner",
      "Filter.2.Name" => "instance-type",
      "Filter.2.Value.1" => "m1.small",
      "Filter.2.Value.2" => "m1.large",
      "InstanceId.1" => "i-12345",
      "InstanceId.2" => "i-56789"
      })

    assert expected == EC2.describe_instances(
      [filters: [tag: ["Owner"], "instance-type": ["m1.small", "m1.large"]],
       instance_ids: ["i-12345", "i-56789"]
      ])
  end

  test "describe_instance_status" do
    expected = build_query(:get, :describe_instance_status, %{})
    assert expected == EC2.describe_instance_status
  end

  test "describe_instance_status with filters and max_results set" do
    expected = build_query(:get, :describe_instance_status, %{
      "Filter.1.Name" => "system-status.reachability",
      "Filter.1.Value.1" => "failed",
      "MaxResults" => 5
      })

    assert expected == EC2.describe_instance_status(
      [filters: ["system-status.reachability": ["failed"]], max_results: 5]
    )
  end

  test "describe_instance_status with instance ids" do
    expected = build_query(:get, :describe_instance_status, %{
      "InstanceId.1" => "i-123456",
      "InstanceId.2" => "i-1a2b3c"
      })

    assert expected == EC2.describe_instance_status(
      [instance_ids: ["i-123456", "i-1a2b3c"]]
    )
  end

  test "terminate_instances" do
    expected = build_query(:post, :terminate_instances, %{
      "InstanceId.1" => "i-123456",
      })

    assert expected == EC2.terminate_instances(["i-123456"])
  end

  test "terminate_instances with dry_run set" do
    expected = build_query(:post, :terminate_instances, %{
      "InstanceId.1" => "i-123456",
      "InstanceId.2" => "i-987654",
      "DryRun" => true
      })

    assert expected == EC2.terminate_instances(["i-123456", "i-987654"], [dry_run: true])
  end

  test "reboot_instances" do
    expected = build_query(:post, :reboot_instances, %{
      "InstanceId.1" => "i-123456"
      })

    assert expected == EC2.reboot_instances(["i-123456"])
  end

  test "reboot_instances with dry_run set" do
    expected = build_query(:post, :reboot_instances, %{
      "InstanceId.1" => "i-123456",
      "DryRun" => true
      })

    assert expected == EC2.reboot_instances(["i-123456"], [dry_run: true])
  end

  test "start_instances" do
    expected = build_query(:post, :start_instances, %{
      "InstanceId.1" => "i-123456",
      "InstanceId.2" => "i-987654"
      })

    assert expected == EC2.start_instances(["i-123456", "i-987654"])
  end

  test "start_instances with dry_run" do
    expected = build_query(:post, :start_instances, %{
      "InstanceId.1" => "i-123456",
      "DryRun" => false
      })

    assert expected == EC2.start_instances(["i-123456"], [dry_run: false])
  end

  test "stop_instances" do
    expected = build_query(:post, :stop_instances, %{
      "InstanceId.1" => "i-123456"
      })

    assert expected == EC2.stop_instances(["i-123456"])
  end

  test "stop_instances by force" do
    expected = build_query(:post, :stop_instances, %{
      "InstanceId.1" => "i-123456",
      "InstanceId.2" => "i-1234abc",
      "Force" => true
      })

    assert expected == EC2.stop_instances(["i-123456", "i-1234abc"], [force: true])
  end

  #################
  # Volumes Tests #
  #################
  test "attach_volume no additional params" do
    expected = build_query(:post, :attach_volume, %{
      "InstanceId" => "i-123456",
      "VolumeId" => "vol-123456",
      "Device" => "/dev/sdb"
      })

    assert expected == EC2.attach_volume("i-123456", "vol-123456", "/dev/sdb")
  end

  test "attach_volume with dry_run" do
    expected = build_query(:post, :attach_volume, %{
      "InstanceId" => "i-123456",
      "VolumeId" => "vol-123456",
      "Device" => "/dev/sdb",
      "DryRun" => false
    })

    assert expected == EC2.attach_volume("i-123456", "vol-123456", "/dev/sdb", [dry_run: false])
  end

  test "detach_volume no additional params" do
    expected = build_query(:post, :detach_volume, %{"VolumeId" => "vol-123456"})

    assert expected == EC2.detach_volume("vol-123456")
  end

  test "detach_volume with force and instance id params" do
    expected = build_query(:post, :detach_volume, %{
      "VolumeId" => "vol-123456",
      "Force" => false,
      "InstanceId" => "i-123456"
    })

    assert expected == EC2.detach_volume("vol-123456", [force: false, instance_id: "i-123456"])
  end

  test "delete_volume with no additional params" do
    expected = build_query(:post, :delete_volume, %{"VolumeId" => "vol-123456"})

    assert expected == EC2.delete_volume("vol-123456")
  end

  test "delete_volume with dry_run param" do
    expected = build_query(:post, :delete_volume, %{
      "VolumeId" => "vol-123456",
      "DryRun" => true})

    assert expected == EC2.delete_volume("vol-123456", [dry_run: true])
  end

  test "create_volume test with tag specifications" do
    expected = build_query(:post, :create_volume, %{
      "AvailabilityZone" => "us-east-1a",
      "TagSpecification.1.ResourceType" => "volume",
      "TagSpecification.1.Tag.1.Key" => "tag_key_foo",
      "TagSpecification.1.Tag.1.Value" => "tag_value_foo",
      "TagSpecification.1.Tag.2.Key" => "tag_key_bar",
      "TagSpecification.1.Tag.2.Value" => "tag_value_bar",

      "TagSpecification.2.ResourceType" => "volume",
      "TagSpecification.2.Tag.1.Key" => "tag_key_baz",
      "TagSpecification.2.Tag.1.Value" => "tag_value_baz",
      })

      assert expected == EC2.create_volume("us-east-1a",
        [tag_specifications: [
          volume:
            [tag_key_foo: "tag_value_foo",
             tag_key_bar: "tag_value_bar"],
          volume:
            [tag_key_baz: "tag_value_baz"]
          ]
        ])
  end

  test "create_volume test with iops, snapshot ID and volume type" do
    expected = build_query(:post, :create_volume, %{
      "AvailabilityZone" => "us-east-1a",
      "SnapshotId" => "snap-123456",
      "VolumeType" => "io1",
      "Iops" => 3000
    })

    assert expected == EC2.create_volume("us-east-1a",
      [snapshot_id: "snap-123456", volume_type: :io1, iops: 3000])
  end

  test "modify_volume test" do
    expected = build_query(:post, :modify_volume, %{"VolumeId" => "vol-123456"})
    assert expected == EC2.modify_volume("vol-123456")
  end

  test "modify_volume test with iops, size, and volume type" do
    expected = build_query(:post, :modify_volume, %{
      "VolumeId" => "vol-123456",
      "Iops" => 3000,
      "Size" => 1024,
      "VolumeType" => "io1"
    })

    assert expected == EC2.modify_volume("vol-123456",
      [iops: 3000, size: 1024, volume_type: :io1])
  end


  ##############
  # Tags Tests #
  ##############
  test "describe_tags" do
    expected = build_query(:get, :describe_tags, %{})

    assert expected == EC2.describe_tags
  end

  test "describe_tags with filters" do
    expected = build_query(:get, :describe_tags, %{
      "Filter.1.Name" => "resource-type",
      "Filter.1.Value.1" => "instance"
      })

    assert expected == EC2.describe_tags(
    [filters: [
      "resource-type": ["instance"]
      ]])
  end

  test "create_tags" do
    expected = build_query(:post, :create_tags, %{
      "ResourceId.1" => "ami-1a2b3c4d",
      "ResourceId.2" => "i-1234567890abcdefg",
      "Tag.1.Key" => "webserver",
      "Tag.1.Value" => "",
      "Tag.2.Key" => "stack",
      "Tag.2.Value" => "Production"
      })

    assert expected == EC2.create_tags(
      ["ami-1a2b3c4d", "i-1234567890abcdefg"],
      ["webserver": "", "stack": "Production"])
  end


  test "delete_tags" do
    expected = build_query(:post, :delete_tags, %{
      "ResourceId.1" => "ami-1a2b3c4ed",
      "Tag.1.Key" => "webserver",
      "Tag.1.Value" => "",
      "Tag.2.Key" => "stack",
      "Tag.2.Value" => ""
      })

    assert expected == EC2.delete_tags(
      ["ami-1a2b3c4ed"],
      [tags: ["webserver": "", "stack": ""]])
  end

  test "delete_tags with dry_run" do
    expected = build_query(:post, :delete_tags, %{
      "ResourceId.1" => "ami-1234567",
      "ResourceId.2" => "i-abc123def456",
      "DryRun" => true
      })

    assert expected == EC2.delete_tags(
    ["ami-1234567", "i-abc123def456"], [dry_run: true])
  end

  ########################################
  # Regions and Availability Zones Tests #
  ########################################

  test "describe_availability_zones with zone names" do
    expected = build_query(:get, :describe_availability_zones, %{
      "ZoneName.1" => "us-east-1d",
      "ZoneName.2" => "us-east-1a"
      })

    assert expected == EC2.describe_availability_zones(
      [zone_names: ["us-east-1d", "us-east-1a"]])
  end

  test "describe_regions" do
    expected = build_query(:get, :describe_regions, %{})

    assert expected == EC2.describe_regions
  end

  test "describe_regions with region names" do
    expected = build_query(:get, :describe_regions, %{
      "RegionName.1" => "us-east-1",
      "RegionName.2" => "eu-west-1"
      })

    assert expected == EC2.describe_regions(
      [region_names: ["us-east-1", "eu-west-1"]])
  end

  ######################
  # Resource Ids Tests #
  ######################
  test "describe_id_format" do
    expected = build_query(:get, :describe_id_format, %{})

    assert expected == EC2.describe_id_format
  end

  test "describe_id_format with instance resource" do
    expected = build_query(:get, :describe_id_format, %{
      "Resource" => "instance"
      })

    assert expected == EC2.describe_id_format([resource: :instance])
  end

  test "modify_id_format" do
    expected = build_query(:post, :modify_id_format, %{
      "Resource" => "instance",
      "UseLongIds" => true
      })

    assert expected == EC2.modify_id_format(:instance, true)
  end

  ############################
  # Account Attributes Tests #
  ############################
  test "describe_account_attributes" do
    expected = build_query(:get, :describe_account_attributes, %{})

    assert expected == EC2.describe_account_attributes
  end

  test "describe_account_attributes with attribute name" do
    expected = build_query(:get, :describe_account_attributes, %{
      "AttributeName.1" => "supported-platforms"
      })

    assert expected ==
      EC2.describe_account_attributes([attribute_names: [:supported_platforms]])
  end

  ################
  # Images Tests #
  ################

  test "copy_image" do
    expected = build_query(:post, :copy_image, %{
      "SourceRegion" => "us-west-2",
      "SourceImageId" => "ami-1a2b3c4d",
      "Name" => "Test AMI"
      })

    assert expected == EC2.copy_image("Test AMI", "ami-1a2b3c4d", "us-west-2")
  end

  test "describe_images" do
    expected = build_query(:get, :describe_images, %{})

    assert expected == EC2.describe_images
  end

  test "describe_images with image ids and owners" do
    expected = build_query(:get, :describe_images, %{
      "ImageId.1" => "ami-1234567",
      "ImageId.2" => "ami-test123",
      "Owner.1" => "test_owner",
      "Owner.2" => "aws"
      })

    assert expected == EC2.describe_images(
      [image_ids: ["ami-1234567", "ami-test123"], owners: ["test_owner", "aws"]])
  end

  test "describe_images with filters" do
    expected = build_query(:get, :describe_images, %{
      "Filter.1.Name" => "is-public",
      "Filter.1.Value.1" => true,
      "Filter.2.Name" => "architecture",
      "Filter.2.Value.1" => "x86_64",
      "Filter.3.Name" => "platform",
      "Filter.3.Value.1" => "windows",
      "Filter.3.Value.2" => "linux"
      })

    assert expected == EC2.describe_images(
      [
        filters: [
          "is-public": [true],
          "architecture": ["x86_64"],
          "platform": ["windows", "linux"]
        ]
      ]
    )
  end

  test "describe_image_attributes" do
    expected = build_query(:get, :describe_image_attribute, %{
      "Attribute" => "description",
      "ImageId" => "ami-1234567"
    })

    assert expected == EC2.describe_image_attribute("ami-1234567", "description")
  end

  #############
  # VPC Tests #
  #############

  test "describe_vpcs" do
    expected = build_query(:get, :describe_vpcs, %{})

    assert expected == EC2.describe_vpcs
  end

  test "describe_vpcs with filters" do
    expected = build_query(:get, :describe_vpcs, %{
      "Filter.1.Name" => "options-id",
      "Filter.1.Value.1" => "dopt-7a8b9c2d",
      "Filter.1.Value.2" => "dopt-2b2a3d3c",
      "Filter.2.Name" => "state",
      "Filter.2.Value.1" => "available"
      })

    assert expected == EC2.describe_vpcs(
      filters: ["options-id": ["dopt-7a8b9c2d", "dopt-2b2a3d3c"],
                "state": ["available"]])
  end

  test "describe vpcs with vpc ids" do
    expected = build_query(:get, :describe_vpcs, %{
      "VpcId.1" => "vpc-123456",
      "VpcId.2" => "vpc-a1b2c3"
      })

    assert expected == EC2.describe_vpcs(
      vpc_ids: ["vpc-123456", "vpc-a1b2c3"]
    )
  end

  test "create_vpc" do
    expected = build_query(:post, :create_vpc, %{
      "CidrBlock" => "10.0.0.0/16"
      })

    assert expected == EC2.create_vpc("10.0.0.0/16")
  end

  test "create_vpc with amazon provided cidr block enabled and instance tenancy set" do
    expected = build_query(:post, :create_vpc, %{
      "CidrBlock"                   => "10.0.0.0/16",
      "InstanceTenancy"             => "dedicated",
      "AmazonProvidedIpv6CidrBlock" => true
      })

    assert expected == EC2.create_vpc("10.0.0.0/16",
      [instance_tenancy: :dedicated, amazon_provided_ipv6_cidr_block: true])
  end

  test "delete_vpc" do
    expected = build_query(:post, :delete_vpc, %{
      "VpcId" => "vpc-1a2b3c4d"
      })

    assert expected == EC2.delete_vpc("vpc-1a2b3c4d")
  end

  test "delete_vpc with dry_run" do
    expected = build_query(:post, :delete_vpc, %{
      "VpcId"  => "vpc-1a2b3c4d",
      "DryRun" => true
      })

    assert expected == EC2.delete_vpc("vpc-1a2b3c4d", [dry_run: true])
  end

  test "describe_vpc_attribute" do
    expected = build_query(:get, :describe_vpc_attribute, %{
      "VpcId"     => "vpc-1a2b3c4d",
      "Attribute" => "enableDnsSupport"
      })

    assert expected == EC2.describe_vpc_attribute("vpc-1a2b3c4d", "enableDnsSupport")
  end

  test "modify_vpc_attribute with enable_dns_hostnames and enable_dns_support" do
    expected = build_query(:post, :modify_vpc_attribute, %{
      "VpcId"                     => "vpc-1a2b3c4d",
      "EnableDnsHostnames.Value"  => true,
      "EnableDnsSupport.Value"    => true
    })

    assert expected == EC2.modify_vpc_attribute("vpc-1a2b3c4d",
      [enable_dns_hostnames: true, enable_dns_support: true]
    )
  end

  #################
  # Subnets Tests #
  #################

  test "describe_subnets" do
    expected = build_query(:get, :describe_subnets, %{})

    assert expected == EC2.describe_subnets
  end

  test "describe_subnets filters" do
    expected = build_query(:get, :describe_subnets, %{
      "Filter.1.Name"    => "vpc-id",
      "Filter.1.Value.1" => "vpc-1a2b3c4d",
      "Filter.1.Value.2" => "vpc-6e7f8a92",
      "Filter.2.Name"    => "state",
      "Filter.2.Value.1" => "available"
      })

    assert expected == EC2.describe_subnets([
        filters: [
          "vpc-id": ["vpc-1a2b3c4d", "vpc-6e7f8a92"],
          "state": ["available"]
        ]
      ])
  end

  test "describe_subnets with subnets" do
    expected = build_query(:get, :describe_subnets, %{
      "SubnetId.1" => "subnet-9d4a7b6c",
      "SubnetId.2" => "subnet-6e7f829e"
      })

    assert expected == EC2.describe_subnets([
      subnet_ids: ["subnet-9d4a7b6c", "subnet-6e7f829e"]
      ])
  end

  test "create_subnet" do
    expected = build_query(:post, :create_subnet, %{
      "VpcId"     => "vpc-1a2b3c4d",
      "CidrBlock" => "10.0.1.0/24"
      })

    assert expected == EC2.create_subnet("vpc-1a2b3c4d", "10.0.1.0/24")
  end

  test "create_subnet with an IPv6 CIDR block" do
    expected = build_query(:post, :create_subnet, %{
      "VpcId"         => "vpc-1a2b3c4d",
      "CidrBlock"     => "10.0.1.0/24",
      "Ipv6CidrBlock" => "2001:db8:1234:1a00::/64"
      })

    assert expected == EC2.create_subnet("vpc-1a2b3c4d", "10.0.1.0/24",
        [ipv6_cidr_block: "2001:db8:1234:1a00::/64"])
  end

  test "delete_subnet" do
    expected = build_query(:post, :delete_subnet, %{
      "SubnetId" => "subnet-9d4a7b6c"
      })

    assert expected == EC2.delete_subnet("subnet-9d4a7b6c")
  end

  test "delete_subnet with dry_run" do
    expected = build_query(:post, :delete_subnet, %{
      "SubnetId" => "subnet-9d4a7b6c",
      "DryRun"   => true
      })

    assert expected == EC2.delete_subnet("subnet-9d4a7b6c", [dry_run: true])
  end

  test "modify_subnet_attribute with map_public_ip_on_launch" do
    expected = build_query(:post, :modify_subnet_attribute, %{
      "SubnetId" => "subnet-9d4a7b6c",
      "MapPublicIpOnLaunch.Value" => true
      })

    assert expected == EC2.modify_subnet_attribute("subnet-9d4a7b6c",
      [map_public_ip_on_launch: true])
  end

  test "modify_subnet_attriute with assign_ipv6_address_on_creation" do
    expected = build_query(:post, :modify_subnet_attribute, %{
      "SubnetId" => "subnet-9d4a7b6c",
      "AssignIpv6AddressOnCreation.Value" => true
      })

    assert expected == EC2.modify_subnet_attribute("subnet-9d4a7b6c",
      [assign_ipv6_address_on_creation: true])
  end

  ##################
  # Key Pair Tests #
  ##################

  test "describe_key_pairs" do
    expected = build_query(:get, :describe_key_pairs, %{})

    assert expected == EC2.describe_key_pairs
  end

  test "describe_key_pairs with filters" do
    expected  = build_query(:get, :describe_key_pairs, %{
      "Filter.1.Name"    => "key-name",
      "Filter.1.Value.1" => "*Dave*"
    })

    assert expected == EC2.describe_key_pairs([
      filters: ["key-name": ["*Dave*"]]
      ])
  end

  test "describe_key_pairs with key_names" do
    expected = build_query(:get, :describe_key_pairs, %{
      "KeyName.1" => "test-key-pair",
      "KeyName.2" => "that-key-pair"
      })

    assert expected == EC2.describe_key_pairs([
      key_names: ["test-key-pair", "that-key-pair"]
      ])
  end

  test "create_key_pair with dry_run" do
    expected = build_query(:post, :create_key_pair, %{
      "KeyName" => "test-key-pair",
      "DryRun"  => true
      })

    assert expected == EC2.create_key_pair("test-key-pair",
      [dry_run: true])
  end

  test "delete_key_pair with dry_run" do
    expected = build_query(:post, :delete_key_pair, %{
      "KeyName" => "test-key-pair",
      "DryRun"  => true
      })

    assert expected == EC2.delete_key_pair("test-key-pair",
      [dry_run: true])
  end

  test "import_key_pair no options" do
    expected = build_query(:post, :import_key_pair, %{
      "KeyName" => "test-key-pair",
      "PublicKeyMaterial" => Base.url_encode64("test")
      })

    assert expected == EC2.import_key_pair(
      "test-key-pair",
      "test")
  end

  #########################
  # Security Groups Tests #
  #########################
  test "describe_security_groups no options" do
    expected = build_query(:get, :describe_security_groups, %{})

    assert expected == EC2.describe_security_groups
  end

  test "describe_security_groups with group_names" do
    expected = build_query(:get, :describe_security_groups, %{
      "GroupName.1" => "Test",
      "GroupName.2" => "WebServer"
    })

    assert expected == EC2.describe_security_groups(
      [group_names: ["Test", "WebServer"]]
    )
  end

  test "describe_security_groups with filters" do
    expected = build_query(:get, :describe_security_groups, %{
      "Filter.1.Name" => "ip-permission.protocol",
      "Filter.1.Value.1" => "tcp",
      "Filter.2.Name" => "ip-permission.from-port",
      "Filter.2.Value.1" => "22",
      "Filter.3.Name" => "ip-permission.to-port",
      "Filter.3.Value.1" => "22",
      "Filter.4.Name" => "ip-permission.group-name",
      "Filter.4.Value.1" => "app_server_group",
      "Filter.4.Value.2" => "database_group"
    })

    assert expected == EC2.describe_security_groups(
      [filters: ["ip-permission.protocol": ["tcp"],
                 "ip-permission.from-port": ["22"],
                 "ip-permission.to-port": ["22"],
                 "ip-permission.group-name": ["app_server_group", "database_group"]
                 ]
       ])
  end

  test "describe_security_groups with group_ids" do
    expected = build_query(:get, :describe_security_groups, %{
      "GroupId.1" => "sg-9bf6ceff",
      "GroupId.2" => "sg-12345678"
      })

    assert expected == EC2.describe_security_groups(
      [group_ids: ["sg-9bf6ceff", "sg-12345678"]]
    )
  end

  test "create_security_group with no options" do
    expected = build_query(:post, :create_security_group, %{
      "GroupName" => "Test",
      "GroupDescription" => "Test Description"
      })

    assert expected == EC2.create_security_group("Test", "Test Description")
  end

  test "create_security_group with vpc_id" do
    expected = build_query(:post, :create_security_group, %{
      "GroupName" => "Test",
      "GroupDescription" => "Test Description",
      "VpcId" => "vpc-3325caf2"
      })

    assert expected == EC2.create_security_group("Test", "Test Description",
      [vpc_id: "vpc-3325caf2"])
  end

  


end
