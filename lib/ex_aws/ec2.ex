defmodule ExAws.EC2 do
  @moduledoc """
  Operations on AWS EC2

  A selection of the most common operations from the EC2 API are implemented here.
  http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Operations.html

  ### Filters

  Many of the `Describe` endpoints allow you to filter based on a number of attributes.
  Refer to the AWS documentation for the specified method for the acceptable filter values.

  When supplying atoms, underscores will be converted to a dash for compatibility
  with the API parameters.

  ### Examples
  ```elixir
  ExAws.EC2.create_vpc("10.0.0.0/16")
  ExAws.EC2.describe_instances(filters: [image_id: "ami-1ecae776"])
  ExAws.EC2.describe_instances(filters: ["network-interface.availability-zone": "us-east-1a"])
  ExAws.EC2.describe_instances(filters: ["tag:elasticbeanstalk:environment-name": "demo"])
  ExAws.EC2.describe_instance_status(instance_id: ["i-e5974f4c"])
  ```
  """
   use ExAws.Utils

  @version "2015-10-01"

  # Available instance types: https://aws.amazon.com/ec2/instance-types/
  @type instance_types ::
    :t2_nano     | :t2_micro    | :t2_small    | :t2_medium  | :t2_large    | :t2_xlarge     | :t2_2xlarge |
    :m4_large    | :m4_xlarge   | :m4_2xlarge  | :m4_4xlarge | :m4_10xlarge | :m4_16xlarge   |
    :m3_medium   | :m3_large    | :m3_xlarge   | :m3_2xlarge |
    :c4_large    | :c4_xlarge   | :c4_2xlarge  | :c4_4xlarge | :c4_8xlarge  |
    :c3_large    | :c3_xlarge   | :c3_2xlarge  | :c3_4xlarge | :c3_8xlarge  |
    :f1_2xlarge  | :f1_16xlarge |
    :g2_2xlarge  | :g2_8xlarge  |
    :p2_xlarge   | :p2_8xlarge  | :p2_16xlarge |
    :r4_large    | :r4_xlarge   | :r4_2xlarge  | :r4_4xlarge | :r4_8xlarge | :r4_16xlarge    |
    :r3_large    | :r3_xlarge   | :r3_2xlarge  | :r3_8xlarge |
    :x1_16xlarge | :x1_32xlarge |
    :d2_xlarge   | :d2_2xlarge  | :d2_4xlarge  | :d2_8xlarge |
    :i2_xlarge   | :i2_2xlarge  | :i2_4xlarge  | :i2_8xlarge |
    :i3_large    | :i3_xlarge   | :i3_2xlarge  | :i3_4xlarge | :i3_8xlarge | :i3_16xlarge

  @type filter :: {
    name :: binary | atom,
    value :: [binary,...]}

  #######################
  # Instance Operations #
  #######################

  @doc """
  Describes one or more instances.
  If you specify the instance IDs or filters, Amazon EC2 returns information for those instances.
  If you do not specify an instance ID or filters, then it'll all the relevant instances

  Example:
  ```
  # Get instances that are only of instance types "m1.small" and "m3.medium"
  EC2.describe_instances([filters: ["instance-type": ["m1.small", "m3.medium"]]])
  ```
  """
  @type describe_instances_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    instance_ids: [binary, ...],
    max_results: integer,
    next_token: binary
  ]
  @spec describe_instances() :: ExAws.Operation.RestQuery.t
  @spec describe_instances(opts :: describe_instances_opts) :: ExAws.Operation.RestQuery.t
  def describe_instances(opts \\ []) do
    query_params = opts
    |> Keyword.delete(:filters)
    |> Keyword.delete(:instance_ids)
    |> normalize_opts

    filters = maybe_format(opts, :filters)
    instance_ids = maybe_format(opts, :instance_ids)

    describe_instance_params =
      Enum.concat([query_params, filters, instance_ids])
      |> Enum.into(%{})

    request(:get, :describe_instances, describe_instance_params)
  end


  @doc """
  Describes the status of one or more instances. By default, only running
  instances are described, unless specified otherwise.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceStatus.html

  Examples:
  ```
  # Get all instance statuses
  EC2.describe_instance_status
  ```
  """
  @type describe_instance_status_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    include_all_instances: boolean,
    instance_ids: [binary, ...],
    max_results: integer,
    next_token: binary
  ]
  @spec describe_instance_status() :: ExAws.Operation.RestQuery.t
  @spec describe_instance_status(opts :: describe_instance_status_opts) :: ExAws.Operation.RestQuery.t
  def describe_instance_status(opts \\ []) do
    query_params = opts
    |> Keyword.delete(:filters)
    |> Keyword.delete(:instance_ids)
    |> normalize_opts

    filters = maybe_format(opts, :filters)
    instance_ids = maybe_format(opts, :instance_ids)

    describe_instance_status_params =
      Enum.concat([query_params, filters, instance_ids])
      |> Enum.into(%{})

    request(:get, :describe_instance_status, describe_instance_status_params)
  end


  @doc """
  Shuts down one or more instances. Terminated instances remain visible after
  termination (for approximately one hour).

  Doc: TODO
  Examples: TODO
  """
  @type terminate_instances_opts :: [
    dry_run: boolean
  ]
  @spec terminate_instances(instance_ids :: [binary, ...]) :: ExAws.Operation.RestQuery.t
  @spec terminate_instances(instance_ids :: [binary, ...], opts :: terminate_instances_opts) :: ExAws.Operation.RestQuery.t
  def terminate_instances(instance_ids, opts \\ []) do
    terminate_instances_params = opts
    |> normalize_opts
    |> Map.merge(format_request(:instance_ids, instance_ids) |> Enum.into(%{}))

    request(:post, :terminate_instances, terminate_instances_params)
  end


  @doc """
  Requests a reboot of one or more instances. This operation is asynchronous; it
  only queues a request to reboot the specified instances.

  Doc: TODO
  Examples: TODO
  """
  @type reboot_instances_opts :: [
    dry_run: boolean
  ]
  @spec reboot_instances(instance_ids :: list(binary)) :: ExAws.Operation.RestQuery.t
  @spec reboot_instances(instance_ids :: list(binary), opts :: reboot_instances_opts) :: ExAws.Operation.RestQuery.t
  def reboot_instances(instance_ids, opts \\ []) do
    reboot_instances_params = opts
    |> normalize_opts
    |> Map.merge(format_request(:instance_ids, instance_ids) |> Enum.into(%{}))

    request(:post, :reboot_instances, reboot_instances_params)
  end


  @doc """
  Starts an Amazon EBS-backed AMI that was previously stopped.

  Doc: TODO
  Examples:
  ```
  # Start instances i-123456 and i-987654
  EC2.start_instances(["i-123456", "i-987654"])

  # Start instance i-123456 with dry_run set to true
  EC2.start_instances(["i-123456"], [dry_run: true])
  ```
  """
  @type start_instances_opts :: [
    additional_info: binary,
    dry_run: boolean,
  ]
  @spec start_instances(instance_ids :: [binary, ...]) :: ExAws.Operation.RestQuery.t
  @spec start_instances(instance_ids :: [binary, ...], opts :: start_instances_opts) :: ExAws.Operation.RestQuery.t
  def start_instances(instance_ids, opts \\ []) do
    start_instances_params = opts
      |> normalize_opts
      |> Map.merge(format_request(:instance_ids, instance_ids) |> Enum.into(%{}))

    request(:post, :start_instances, start_instances_params)
  end

  @doc """
  Stops an Amazon EBS-backed AMI that was previously started.

  Doc: TODO
  Examples:
  ```
  EC2.stop_instances(["i-123456"])
  EC2.stop_instances(["i-123456", "i-1234abc"], [force: true])
  ```
  """
  @type stop_instances_opts :: [
    dry_run: boolean,
    force: boolean
  ]
  @spec stop_instances(instance_ids :: [binary, ...]) :: ExAws.Operation.RestQuery.t
  @spec stop_instances(instance_ids :: [binary, ...], opts :: stop_instances_opts) :: ExAws.Operation.RestQuery.t
  def stop_instances(instance_ids, opts \\ []) do
    stop_instances_params = opts
      |> normalize_opts
      |> Map.merge(format_request(:instance_ids, instance_ids) |> Enum.into(%{}))

    request(:post, :stop_instances, stop_instances_params)
  end


  # @doc """
  # Submits feedback about the status of an instance. The instance must be in the
  # running state.
  # """
  # @type report_instance_status_opts :: [
  #   description: binary,
  #   dry_run: boolean,
  #   end_time: binary,
  # ]
  # @spec report_instance_status(instance_ids :: [binary, ...], status :: binary) :: ExAws.Operation.RestQuery.t
  # @spec report_instance_status(instance_ids :: [binary, ...], status :: binary, opts :: report_instance_status_opts) :: ExAws.Operation.RestQuery.t
  # def report_instance_status(instance_ids, status, opts \\ []) do
  #   query_params = opts
  #   |> normalize_opts
  #   |> Map.merge(%{
  #     "Action"  => "ReportInstanceStatus",
  #     "Version" => @version,
  #     "Status"  => status
  #     })
  #   |> Map.merge(list_builder(instance_ids, "InstanceId", 1, %{}))
  #
  #   request(:get, "/", query_params)
  # end

  ##################
  # AMI Operations #
  ##################

  # @type create_image_opts :: [
  #   {:block_device_mapping, block_device_mapping_list}          |
  #   {:description, binary}                                      |
  #   {:dry_run, boolean}                                         |
  #   {:no_reboot, boolean}
  # ]
  # @doc """
  # Creates an Amazon EBS-backed AMI from an Amazon EBS-backed instance
  # that is either running or stopped.
  # """
  # @spec create_image(instance_id :: binary, name :: binary) :: ExAws.Operation.RestQuery.t
  # @spec create_image(instance_id :: binary, name :: binary, opts :: create_image_opts) :: ExAws.Operation.RestQuery.t
  # def create_image(instance_id, name, opts \\ []) do
  #   query_params = opts
  #   |> normalize_opts
  #   |> Map.merge(%{
  #     "Action"     => "CreateImage",
  #     "Version"    => @version,
  #     "InstanceId" => instance_id,
  #     "Name"       => name
  #     })
  #
  #   request(:post, "/", query_params)
  # end
  #

  @doc """
  Initiates the copy of an AMI from the specified source region to the current
  region. You specify the destination region by using its endpoint when
  making the request.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CopyImage.html

  Examples: TODO
  TODO: Write parser
  """
  @type copy_image_opts :: [
    client_token: binary,
    description: binary,
    dry_run: boolean,
    encrypted: boolean,
    kms_key_id: binary
  ]
  @spec copy_image(name :: binary, source_image_id :: binary, source_region :: binary) :: ExAws.Operation.RestQuery.t
  @spec copy_image(name :: binary, source_image_id :: binary, source_region :: binary, opts :: copy_image_opts) :: ExAws.Operation.RestQuery.t
  def copy_image(name, source_image_id, source_region, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "Name"          => name,
      "SourceImageId" => source_image_id,
      "SourceRegion"  => source_region
    })

    request(:post, :copy_image, query_params)
  end


  @doc """
  Describes one or more of the images (AMIs, AKIs, and ARIs) available to you.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeImages.html

  TODO: Write parser
  Examples:
  ```
  EC2.describe_images
  EC2.describe_images([image_ids: ["ami-1234567", "ami-test123"], owners: ["test_owner", "aws"]])
  ```
  """
  @type describe_images_opts :: [
    dry_run: boolean,
    executable_by_list: [binary, ...],
    filters: [filter, ...],
    image_ids: [binary, ...],
    owners: [binary, ...]
  ]
  @spec describe_images() :: ExAws.Operation.RestQuery.t
  @spec describe_images(opts :: describe_images_opts) :: ExAws.Operation.RestQuery.t
  def describe_images(opts \\ []) do
    normalized_opts = opts
    |> Keyword.delete(:filters)
    |> Keyword.delete(:image_ids)
    |> Keyword.delete(:owners)
    |> Keyword.delete(:executable_by_list)
    |> normalize_opts

    filters = opts |> maybe_format(:filters)
    image_ids = opts |> maybe_format(:image_ids)
    owners = opts |> maybe_format(:owners)
    executable_by_list = opts |> maybe_format(:executable_by_list)

    describe_images_params =
      Enum.concat([normalized_opts, image_ids, filters, owners, executable_by_list])
      |> Enum.into(%{})

    request(:get, :describe_images, describe_images_params)
  end


  @doc """
  Describes the specified attribute of the specified AMI. You can specify
  only one attribute at a time.
  """
  @type describe_image_attribute_opts :: [
    dry_run: boolean
  ]
  @spec describe_image_attribute(image_id :: binary, attribute :: binary) :: ExAws.Operation.RestQuery.t
  @spec describe_image_attribute(image_id :: binary, attribute :: binary, opts :: describe_image_attribute_opts) :: ExAws.Operation.RestQuery.t
  def describe_image_attribute(image_id, attribute, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "ImageId"   => image_id,
      "Attribute" => attribute
      })

    request(:get, :describe_image_attribute, query_params)
  end

  # @type modify_image_attribute_opts :: [
  #   {:attribute, binary}                                  |
  #   {:description, attribute_value}                       |
  #   {:dry_run, boolean}                                   |
  #   {:launch_permission, launch_permission_modifications} |
  #   {:operation_type, :add | :remove}                     |
  #   {:product_code, :add | :remove}                       |
  #   {:user_group, [binary]}                               |
  #   {:value, binary}
  # ]
  # @doc """
  # Modifies the specified attribute of the specified AMI. You can specify only
  # one attribute at a time.
  # """
  # @spec modify_image_attribute(image_id :: binary) :: ExAws.Operation.RestQuery.t
  # @spec modify_image_attribute(image_id :: binary, opts :: modify_image_attribute_opts) :: ExAws.Operation.RestQuery.t
  # def modify_image_attribute(image_id, opts \\ []) do
  #   query_params = opts
  #   |> normalize_opts
  #   |> Map.merge(%{
  #     "Action"  => "ModifyImageAttribute",
  #     "Version" => @version,
  #     "ImageId" => image_id
  #     })
  #
  #   request(:post, "/", query_params)
  # end
  #

  @doc """
  Resets an attribute of an AMI to its default value.
  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ResetImageAttribute.html

  NOTE: You can currently only reset the launchPermission attribute. Please refer to the
  doc in case something has changed.

  TODO: Write parsers and write examples
  """
  @type reset_image_attribute_opts :: [
    dry_run: boolean
  ]
  @spec reset_image_attribute(image_id :: binary, attribute :: binary) :: ExAws.Operation.RestQuery.t
  @spec reset_image_attribute(image_id :: binary, attribute :: binary, opts :: reset_image_attribute_opts) :: ExAws.Operation.RestQuery.t
  def reset_image_attribute(image_id, attribute, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "ImageId" => image_id,
      "Attribute" => attribute
      })

    request(:post, :reset_image_attribute, query_params)
  end
  #
  # @type register_image_opts :: [
  #   {:architecture, :i386 | :x86_64}                            |
  #   {:block_device_mapping, block_device_mapping_list}          |
  #   {:description, binary}                                      |
  #   {:dry_run, boolean}                                         |
  #   {:image_location, binary}                                   |
  #   {:kernel_id, binary}                                        |
  #   {:ram_disk_id, binary}                                      |
  #   {:root_device_name, binary}                                 |
  #   {:sriov_net_support, binary}                                |
  #   {:virtualization_type, binary}
  # ]
  # @doc """
  # Registers an AMI. When you're creating an AMI, this is the final step you
  # must complete before you can launch an instance from the AMI.
  # """
  # @spec register_image(name :: binary) :: ExAws.Operation.RestQuery.t
  # @spec register_image(name :: binary, opts :: register_image_opts) :: ExAws.Operation.RestQuery.t
  # def register_image(name, opts \\ []) do
  #   query_params = opts
  #   |> normalize_opts
  #   |> Map.merge(%{
  #     "Action"  => "RegisterImage",
  #     "Version" => @version,
  #     "Name"    => name
  #     })
  #
  #   request(:post, "/", query_params)
  # end
  #

  @doc """
  Deregisters the specified AMI. After you deregister an AMI, it can't be used
  to launch new instances.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeregisterImage.html
  TODO: Examples and write parser
  """
  @type deregister_image_opts :: [
    {:dry_run, boolean}
  ]
  @spec deregister_image(image_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec deregister_image(image_id :: binary, opts :: deregister_image_opts) :: ExAws.Operation.RestQuery.t
  def deregister_image(image_id, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"ImageId" => image_id})

    request(:post, :deregister_image, query_params)
  end


  #####################
  # Volume Operations #
  #####################

  @doc """
  Attaches a volume to a specified instance

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_AttachVolume.html

  Examples
  ```
  EC2.attach_volume("i-123456", "vol-123456", "/dev/sdh")
  EC2.attach_volume("i-123456", "vol-123456", "/dev/sdj", [dry_run: false])
  ```
  """
  @type attach_volume_opts :: [
    dry_run: boolean
  ]
  @spec attach_volume(instance_id :: binary, volume_id :: binary, device :: binary, opts :: attach_volume_opts) :: ExAws.Operation.RestQuery.t
  def attach_volume(instance_id, volume_id, device, opts \\ []) do
    params = opts
      |> normalize_opts
      |> Map.merge(%{
          "InstanceId" => instance_id,
          "VolumeId" => volume_id,
          "Device" => device
        })

    request(:post, :attach_volume, params)
  end

  @doc """
  Detaches a specific volume

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DetachVolume.html

  Examples
  ```
  EC2.detach_volume("vol-123456")
  EC2.detach_volume("vol-123456", [instance_id: "i-0b32fa2473580afa3", force: true])
  ```
  """
  @type detach_volume_opts :: [
    instance_id: binary,
    force: boolean,
    dry_run: boolean,
    device: binary
  ]
  @spec detach_volume(volume_id :: binary, opts :: detach_volume_opts) :: ExAws.Operation.RestQuery.t
  def detach_volume(volume_id, opts \\ []) do
    params = opts
      |> normalize_opts
      |> Map.merge(%{"VolumeId" => volume_id})

    request(:post, :detach_volume, params)
  end


  @doc """
  Creates an EBS volume that can be attached to an instance in the same
  Availability Zone

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateVolume.html
  """
  @type volume_type ::
    :standard | :io1 | :gp2 | :sc1 | :st1
  @type resource_type ::
    :customer_gateway       |
    :dhcp_options           |
    :image                  |
    :instance               |
    :internet_gateway       |
    :network_acl            |
    :network_interface      |
    :reserved_instances     |
    :route_table            |
    :snapshot               |
    :spot_instances_request |
    :subnet                 |
    :security_group         |
    :volume                 |
    :vpc                    |
    :vpn_connection         |
    :vpn_gateway
  @type tag :: {key :: atom, value :: binary}
  @type tag_specification :: {
    resource_type :: resource_type,
    tags :: [tag, ...]
  }
  @type create_volume_opts :: [
    dry_run: boolean,
    encrypted: boolean,
    iops: integer,
    kms_key_id: binary,
    size: integer,
    snapshot_id: binary,
    tag_specifications: [tag_specification, ...],
    volume_type: volume_type
  ]
  @spec create_volume(availability_zone :: binary, opts :: create_volume_opts) :: ExAws.Operation.RestQuery.t
  def create_volume(availability_zone, opts \\ []) do
    normalized_params = opts
    |> Keyword.delete(:tag_specifications)
    |> Keyword.delete(:volume_type)
    |> normalize_opts
    |> Map.merge(%{"AvailabilityZone" => availability_zone})

    tag_specifications = maybe_format opts, :tag_specifications

    volume_type = maybe_format opts, :volume_type

    create_volume_params = Enum.concat([
      normalized_params,
      tag_specifications,
      volume_type
    ])
    |> Enum.into(%{})

    request(:post, :create_volume, create_volume_params)
  end


  @doc """
  Deletes a specified volume

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteVolume.html

  Examples:
  ```
  EC2.delete_volume("vol-123456")
  EC2.delete_volume("vol-123456", [dry_run: true])
  ```
  """
  @type delete_volume_opts :: [
    dry_run: boolean
  ]
  @spec delete_volume(volume_id :: binary, opts :: delete_volume_opts) :: ExAws.Operation.RestQuery.t
  def delete_volume(volume_id, opts \\ []) do
    params = opts
      |> normalize_opts
      |> Map.merge(%{"VolumeId" => volume_id})

    request(:post, :delete_volume, params)
  end


  @doc """
  Modifies a specified volume.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyVolume.html

  Examples:
  ```
  EC2.modify_volume("vol-123456", [iops: 3000, size: 1024, volume_type: :io1])
  ```
  """
  @type modify_volume_opts :: [
    dry_run: boolean,
    iops: integer,
    size: integer,
    volume_type: volume_type
  ]
  @spec modify_volume(volume_id :: binary, opts :: modify_volume_opts) :: ExAws.Operation.RestQuery.t
  def modify_volume(volume_id, opts \\ []) do
    modify_volume_params = opts
    |> Keyword.delete(:volume_type)
    |> normalize_opts
    |> Map.merge(%{"VolumeId" => volume_id})
    |> Map.merge(maybe_format(opts, :volume_type) |> Enum.into(%{}))

    request(:post, :modify_volume, modify_volume_params)
  end

  #######################
  # Snapshot Operations #
  #######################

  @doc """
  Describes one or more of the EBS snapshots available to you.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSnapshots.html
  """
  # @type describe_snapshots_opts :: [
  #   {:dry_run, boolean}                            |
  #   {:filters, [filter]}                           |
  #   {:max_results, integer}                        |
  #   {:next_token, binary}                          |
  #   {:owner, [binary]}                             |
  #   {:restorable_by, [binary]}                     |
  #   {:snapshot_id, [binary]}
  # ]
  # @spec describe_snapshots() :: ExAws.Operation.RestQuery.t
  # @spec describe_snapshots(opts :: describe_snapshots_opts) :: ExAws.Operation.RestQuery.t
  # def describe_snapshots(opts \\ []) do
  #   query_params = opts
  #   |> normalize_opts
  #   |> Map.merge(%{
  #     "Action"  => "DescribeSnapshots",
  #     "Version" => @version
  #     })
  #
  #   request(:get, "/", query_params)
  # end

  @doc """
  Creates a snapshot of an EBS volume and stores it in Amazon S3.
  You can use snapshots for backups, to make copies of EBS volumes, and to
  save data before shutting down an instance.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateSnapshot.html
  """
  @type create_snapshot_opts :: [
    description: binary,
    dry_run: boolean
  ]
  @spec create_snapshot(volume_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec create_snapshot(volume_id :: binary, opts :: create_snapshot_opts) :: ExAws.Operation.RestQuery.t
  def create_snapshot(volume_id, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"VolumeId" => volume_id})

    request(:post, :create_snapshot, query_params)
  end

  @doc """
  Copies a point-in-time snapshot of an EBS volume and stores it in Amazon S3.
  You can copy the snapshot within the same region or from one region to
  another.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CopySnapshot.html
  """
  @type copy_snapshot_opts :: [
    description: binary,
    destination_region: binary,
    dry_run: boolean,
    encrypted: boolean,
    kms_key_id: binary,
    presigned_url: binary
  ]
  @spec copy_snapshot(source_snapshot_id :: binary, source_region :: binary) :: ExAws.Operation.RestQuery.t
  @spec copy_snapshot(source_snapshot_id :: binary, source_region :: binary, opts :: copy_snapshot_opts) :: ExAws.Operation.RestQuery.t
  def copy_snapshot(source_snapshot_id, source_region, opts \\ []) do
    query_params = opts
      |> normalize_opts
      |> Map.merge(%{
      "SourceSnapshotId" => source_snapshot_id,
      "SourceRegion"     => source_region
    })

    request(:post, :copy_snapshot, query_params)
  end

  @doc """
  Deletes the specified snapshot.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteSnapshot.html
  """
  @type delete_snapshot_opts :: [
    dry_run: boolean
  ]
  @spec delete_snapshot(snapshot_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec delete_snapshot(snapshot_id :: binary, opts :: delete_snapshot_opts) :: ExAws.Operation.RestQuery.t
  def delete_snapshot(snapshot_id, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"SnapshotId" => snapshot_id})

    request(:post, :delete_snapshot, query_params)
  end


  @doc """
  Describes the specified attribute of the specified snapshot. You can specify
  only one attribute at a time.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSnapshotAttribute.html
  """
  @type describe_snapshot_attribute_opts :: [
    dry_run: boolean
  ]
  @spec describe_snapshot_attribute(snapshot_id :: binary, attribute :: binary) :: ExAws.Operation.RestQuery.t
  @spec describe_snapshot_attribute(snapshot_id :: binary, attribute :: binary, opts :: describe_snapshot_attribute_opts) :: ExAws.Operation.RestQuery.t
  def describe_snapshot_attribute(snapshot_id, attribute, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "SnapshotId" => snapshot_id,
      "Attribute"  => attribute
      })

    request(:get, :describe_snapshot_attribute, query_params)
  end

  @doc """
  Adds or removes permission settings for the specified snapshot.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifySnapshotAttribute.html
  """
  # @type create_volume_permission :: [
  #   user_id: [binary, ...],
  #   group: [binary, ...]
  # ]
  # @type create_volume_permissions_modifications :: [
  #   add: [create_volume_permission, ...]
  #   remove: [create_volume_permission, ...]
  # ]
  # @type modify_snapshot_attribute_opts :: [
  #   attribute: [:product_codes | :create_volume_permission],
  #   create_volume_permission: create_volume_permission_modifications,
  #   dry_run: boolean,
  #   user_groups: [binary, ...],
  #   user_ids: [binary, ...]
  # ]
  # @spec modify_snapshot_attribute(snapshot_id :: binary) :: ExAws.Operation.RestQuery.t
  # @spec modify_snapshot_attribute(snapshot_id :: binary, opts :: modify_snapshot_attribute_opts) :: ExAws.Operation.RestQuery.t
  # def modify_snapshot_attribute(snapshot_id, opts \\ []) do
  #   query_params = opts
  #   |> Keyword.delete(:attribute)
  #   |> Keyword.delete(:create_volume_permission)
  #   |> Keyword.delete(:user_groups)
  #   |> Keyword.delete(:user_ids)
  #   |> normalize_opts
  #   |> Map.merge(%{"SnapshotId" => snapshot_id})
  #
  #   request(:post, "/", query_params)
  # end

  @doc """
  Resets permission settings for the specified snapshot.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ResetSnapshotAttribute.html
  """
  @type reset_snapshot_attribute_opts :: [
    dry_run: boolean
  ]
  @spec reset_snapshot_attribute(snapshot_id :: binary, attribute :: binary) :: ExAws.Operation.RestQuery.t
  @spec reset_snapshot_attribute(snapshot_id :: binary, attribute :: binary, opts :: reset_snapshot_attribute_opts) :: ExAws.Operation.RestQuery.t
  def reset_snapshot_attribute(snapshot_id, attribute, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "SnapshotId" => snapshot_id,
      "Attribute"  => attribute
      })

    request(:post, :reset_snapshot_attribute, query_params)
  end


  ############################
  ### Bundle Tasks Actions ###
  ############################

  @doc """
  Bundles an Amazon instance store-backed Windows instance.
  During bundling, only the root device volume (C:\) is bundled. Data on other
  instance store volumes is not preserved.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_BundleInstance.html
  """
  @type bundle_instance_opts :: [
    dry_run: boolean
  ]
  @spec bundle_instance(instance_id :: binary, s3_storage) :: ExAws.Operation.RestQuery.t
  @spec bundle_instance(instance_id :: binary, s3_storage, opts :: bundle_instance_opts) :: ExAws.Operation.RestQuery.t
  def bundle_instance(instance_id, {s3_aws_access_key_id, s3_bucket, s3_prefix, s3_upload_policy, s3_upload_policy_sig}, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "InstanceId"                       => instance_id,
      "Storage.S3.AWSAccessKeyId"        => s3_aws_access_key_id,
      "Storage.S3.Bucket"                => s3_bucket,
      "Storage.S3.Prefix"                => s3_prefix,
      "Storage.S3.UploadPolicy"          => s3_upload_policy,
      "Storage.S3.UploadPolicySignature" => s3_upload_policy_sig
      })

    request(:post, :bundle_instance, query_params)
  end

  @doc """
  Cancels a bundling operation for an instance store-backed Windows instance.
  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CancelBundleTask.html
  """
  @type cancel_bundle_task_opts :: [
    dry_run: boolean
  ]
  @spec cancel_bundle_task(bundle_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec cancel_bundle_task(bundle_id :: binary, opts :: cancel_bundle_task_opts) :: ExAws.Operation.RestQuery.t
  def cancel_bundle_task(bundle_id, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "BundleId" => bundle_id
      })

    request(:post, :cancel_bundle_task, query_params)
  end


  @doc """
  Describes one or more of your bundling tasks.
  """
  @type bundle_instance_states ::
  :pending              |
  :waiting_for_shutdown |
  :bundling             |
  :storing              |
  :cancelling           |
  :complete             |
  :failed
  @type describe_bundle_tasks_opts :: [
    bundle_ids: [binary, ...],
    dry_run: boolean,
    filters: [filter, ...]
  ]
  @spec describe_bundle_tasks() :: ExAws.Operation.RestQuery.t
  @spec describe_bundle_tasks(opts :: describe_bundle_tasks_opts) :: ExAws.Operation.RestQuery.t
  def describe_bundle_tasks(opts \\ []) do
    query_params = opts
    |> Keyword.delete(:bundle_ids)
    |> Keyword.delete(:filters)
    |> normalize_opts

    request(:get, "/", query_params)
  end

  ###################
  # Tags Operations #
  ###################

  @doc """
  Describes one or more of the tags for your EC2 resources.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeTags.html
  NOTE: If you need to pass in filters, pay special attention to what is allowed to be
  passed in in the doc.

  Examples: TODO
  TODO: write parser
  ```
  ```
  """
  @type describe_tags_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    max_results: integer,
    next_token: binary
  ]
  @spec describe_tags() :: ExAws.Operation.RestQuery.t
  @spec describe_tags(opts :: describe_tags_opts) :: ExAws.Operation.RestQuery.t
  def describe_tags(opts \\ []) do
    describe_tags_params = opts
    |> Keyword.delete(:filters)
    |> normalize_opts
    |> Map.merge(maybe_format(opts, :filters) |> Enum.into(%{}))

    request(:get, :describe_tags, describe_tags_params)
  end

  @doc """
  Adds or overwrites one or more tags for the specified Amazon EC2 resource or
  resources. Each resource can have a maximum of 10 tags. Each tag consists of
  a key and optional value. Tag keys must be unique per resource.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateTags.html
  Examples: TODO
  TODO: write parser
  """
  @type create_tags_opts :: [
    dry_run: boolean
  ]
  @spec create_tags(resource_ids :: [binary, ...], tags :: [tag, ...]) :: ExAws.Operation.RestQuery.t
  @spec create_tags(resource_ids :: [binary, ...], tags :: [tag, ...], opts :: create_tags_opts) :: ExAws.Operation.RestQuery.t
  def create_tags(resource_ids, tags, opts \\ []) do
    create_tags_params = opts
    |> normalize_opts
    |> Map.merge(format_request(:resource_ids, resource_ids) |> Enum.into(%{}))
    |> Map.merge(format_request(:tags, tags) |> Enum.into(%{}))

    request(:post, :create_tags, create_tags_params)
  end

  @doc """
  Deletes the specified set of tags from the specified set of resources.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteTags.html
  Examples: TODO
  TODO: write parser
  ```
  ```
  """
  @type delete_tags_opts :: [
    dry_run: boolean,
    tags: [tag, ...]
  ]
  @spec delete_tags(resource_ids :: [binary, ...]) :: ExAws.Operation.RestQuery.t
  @spec delete_tags(resource_ids :: [binary, ...], opts :: delete_tags_opts) :: ExAws.Operation.RestQuery.t
  def delete_tags(resource_ids, opts \\ []) do
    delete_tags_params = opts
    |> Keyword.delete(:tags)
    |> normalize_opts
    |> Map.merge(format_request(:resource_ids, resource_ids) |> Enum.into(%{}))
    |> Map.merge(maybe_format(opts, :tags) |> Enum.into(%{}))

    request(:post, :delete_tags, delete_tags_params)
  end


  #############################################
  # Regions and Availability Zones Operations #
  #############################################

  @doc """
  Describes one or more of the Availability Zones that are available to you.
  The results include zones only for the region you're currently using.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeAvailabilityZones.html

  TODO: write parser
  Examples:
  ```
  EC2.describe_availability_zones
  EC2.describe_availability_zones([zone_names: ["us-east-1d"]])
  ```
  """
  @type describe_availability_zones_opts :: [
    dry_run: boolean,
    zone_names: [binary, ...],
    filters: [filter, ...]
  ]
  @spec describe_availability_zones() :: ExAws.Operation.RestQuery.t
  @spec describe_availability_zones(opts :: describe_availability_zones_opts) :: ExAws.Operation.RestQuery.t
  def describe_availability_zones(opts \\ []) do
    desc_availability_zones_params =
      opts
        |> Keyword.delete(:zone_names)
        |> Keyword.delete(:filters)
        |> normalize_opts
        |> Map.merge(maybe_format(opts, :zone_names) |> Enum.into(%{}))
        |> Map.merge(maybe_format(opts, :filters) |> Enum.into(%{}))

    request(:get, :describe_availability_zones, desc_availability_zones_params)
  end


  @doc """
  Describes one or more regions that are currently available to you.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeRegions.html

  TODO: write parser
  Examples:
  ```
  EC2.describe_regions
  EC2.describe_regions([region_names: ["us-east-1", "eu-west-1"]])
  """
  @type describe_regions_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    region_names: [binary, ...]
  ]
  @spec describe_regions() :: ExAws.Operation.RestQuery.t
  @spec describe_regions(opts :: describe_regions_opts) :: ExAws.Operation.RestQuery.t
  def describe_regions(opts \\ []) do
    desc_regions_params =
      opts
        |> Keyword.delete(:filters)
        |> Keyword.delete(:region_names)
        |> normalize_opts
        |> Map.merge(maybe_format(opts, :region_names) |> Enum.into(%{}))
        |> Map.merge(maybe_format(opts, :filters) |> Enum.into(%{}))

    request(:get, :describe_regions, desc_regions_params)
  end

  ###########################
  # Resource ID Operatioons #
  ###########################

  @doc """
  Describes the ID format settings for your resources on a per-region basis,
  for example, to view which resource types are enabled for longer IDs.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeIdFormat.html
  Examples: TODO
  TODO: write parser
  ```

  ```
  """
  @type resource :: [
    :instance    |
    :reservation |
    :snapshot    |
    :volume
  ]
  @type describe_id_format_opts :: [
    resource: resource
  ]
  @spec describe_id_format() :: ExAws.Operation.RestQuery.t
  @spec describe_id_format(opts :: describe_id_format_opts) :: ExAws.Operation.RestQuery.t
  def describe_id_format(opts \\ []) do
    desc_id_format_params = opts
    |> Keyword.delete(:resource)
    |> Enum.into(%{})
    |> Map.merge(maybe_format(opts, :resource) |> Enum.into(%{}))

    request(:get, :describe_id_format, desc_id_format_params)
  end

  @doc """
  Modifies the ID format for the specified resource on a per-region basis.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyIdFormat.html
  Examples:
  ```
  EC2.modify_id_format(:instance, true)
  ```
  TODO: write parser
  """
  @spec modify_id_format(resource :: resource, use_long_ids :: boolean) :: ExAws.Operation.RestQuery.t
  def modify_id_format(resource, use_long_ids) do
    modify_id_format_params = %{
      "Resource" => resource |> Atom.to_string,
      "UseLongIds" => use_long_ids
    }

    request(:post, :modify_id_format, modify_id_format_params)
  end

  #################################
  # Account Attributes Operations #
  #################################

  @doc """
  Describes attributes of your AWS account.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeAccountAttributes.html
  Examples: TODO:
  ```
  ```
  TODO: write parser
  """
  @type attribute_name :: [
    :supported_platforms |
    :default_vpc
  ]
  @type describe_account_attributes_opts :: [
    attribute_names: [attribute_name, ...],
    dry_run: boolean
  ]
  @spec describe_account_attributes() :: ExAws.Operation.RestQuery.t
  @spec describe_account_attributes(opts :: describe_account_attributes_opts) :: ExAws.Operation.RestQuery.t
  def describe_account_attributes(opts \\ []) do
    query_params =
      opts
      |> Keyword.delete(:attribute_names)
      |> normalize_opts
      |> Map.merge(maybe_format(opts, :attribute_names) |> Enum.into(%{}))

    request(:get, :describe_account_attributes, query_params)
  end

  ####################
  ### VPCs Actions ###
  ####################

  @doc """
  Describes one or more of your VPCs.

  Doc: TODO
  Examples: TODO
  TODO parser
  """
  @type describe_vpcs_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    vpc_ids: [binary, ...]
  ]
  @spec describe_vpcs() :: ExAws.Operation.RestQuery.t
  @spec describe_vpcs(opts :: describe_vpcs_opts) :: ExAws.Operation.RestQuery.t
  def describe_vpcs(opts \\ []) do
    normalized_opts = opts
    |> Keyword.delete(:filters)
    |> Keyword.delete(:vpc_ids)
    |> normalize_opts

    filters = maybe_format(opts, :filters)
    vpc_ids = maybe_format(opts, :vpc_ids)

    query_params = Enum.concat([normalized_opts, filters, vpc_ids])
    |> Enum.into(%{})

    request(:get, :describe_vpcs, query_params)
  end

  @doc """
  Creates a VPC with the specified CIDR block.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateVpc.html
  TODO: Write parser and write examples
  """
  @type create_vpc_opts :: [
    dry_run: boolean,
    instance_tenancy: [:default | :dedicated | :host],
    amazon_provided_ipv6_cidr_block: boolean
  ]
  @spec create_vpc(cidr_block :: binary) :: ExAws.Operation.RestQuery.t
  @spec create_vpc(cidr_block :: binary, opts :: create_vpc_opts) :: ExAws.Operation.RestQuery.t
  def create_vpc(cidr_block, opts \\ []) do
    query_params = opts
    |> Keyword.delete(:instance_tenancy)
    |> normalize_opts
    |> Map.merge(%{"CidrBlock" => cidr_block})
    |> Map.merge(maybe_format(opts, :instance_tenancy) |> Enum.into(%{}))

    request(:post, :create_vpc, query_params)
  end


  @doc """
  Deletes the specified VPC.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteVpc.html
  Examples: TODO
  TODO: write parser
  """
  @type delete_vpc_opts :: [
    dry_run: boolean
  ]
  @spec delete_vpc(vpc_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec delete_vpc(vpc_id :: binary, opts :: delete_vpc_opts) :: ExAws.Operation.RestQuery.t
  def delete_vpc(vpc_id, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"VpcId" => vpc_id})

    request(:post, :delete_vpc, query_params)
  end


  @doc """
  Describes the specified attribute of the specified VPC. You can specify only one attribute at a time.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeVpcAttribute.html
  Examples: TODO
  TODO: write parser
  """
  @type describe_vpc_attribute_opts :: [
    dry_run: boolean
  ]
  @spec describe_vpc_attribute(vpc_id :: binary, attribute :: binary) :: ExAws.Operation.RestQuery.t
  @spec describe_vpc_attribute(vpc_id :: binary, attribute :: binary, opts :: describe_vpc_attribute_opts) :: ExAws.Operation.RestQuery.t
  def describe_vpc_attribute(vpc_id, attribute, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "VpcId"     => vpc_id,
      "Attribute" => attribute
      })

    request(:get, :describe_vpc_attribute, query_params)
  end


  @doc """
  Modifies the specified attribute of the specified VPC.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyVpcAttribute.html
  Example: TODO
  TODO: Write parser
  """
  @type modify_vpc_attribute_opts :: [
    enable_dns_hostnames: boolean,
    enable_dns_support: boolean
  ]
  @spec modify_vpc_attribute(vpc_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec modify_vpc_attribute(vpc_id :: binary, opts :: modify_vpc_attribute_opts) :: ExAws.Operation.RestQuery.t
  def modify_vpc_attribute(vpc_id, opts \\ []) do
    enable_dns_hostnames = maybe_format(opts, :enable_dns_hostnames)
    enable_dns_support = maybe_format(opts, :enable_dns_support)

    query_params =
    Enum.concat([enable_dns_hostnames, enable_dns_support])
    |> Enum.into(%{})
    |> Map.merge(%{
      "VpcId" => vpc_id
      })

    request(:post, :modify_vpc_attribute, query_params)
  end

  ######################
  # Subnets Operations #
  ######################

  @doc """
  Describes one or more of your subnets.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSubnets.html
  Examples: TODO
  TODO Parser
  """
  @type describe_subnets_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    subnet_ids: [binary, ...]
  ]
  @spec describe_subnets() :: ExAws.Operation.RestQuery.t
  @spec describe_subnets(opts :: describe_subnets_opts) :: ExAws.Operation.RestQuery.t
  def describe_subnets(opts \\ []) do
    normalized_params = opts
    |> Keyword.delete(:filters)
    |> Keyword.delete(:subnet_ids)
    |> normalize_opts

    subnet_ids = maybe_format(opts, :subnet_ids)
    filters = maybe_format(opts, :filters)

    query_params =
      Enum.concat([normalized_params, subnet_ids, filters])
      |> Enum.into(%{})

    request(:get, :describe_subnets, query_params)
  end

  @doc """
  Creates a subnet in an existing VPC.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateSubnet.html
  Examples: TODO
  TODO Parser
  """
  @type create_subnet_opts :: [
    availability_zone: binary,
    dry_run: boolean,
    ipv6_cidr_block: binary
  ]
  @spec create_subnet(vpc_id :: binary, cidr_block :: binary) :: ExAws.Operation.RestQuery.t
  @spec create_subnet(vpc_id :: binary, cidr_block :: binary, opts :: create_subnet_opts) :: ExAws.Operation.RestQuery.t
  def create_subnet(vpc_id, cidr_block, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
      "VpcId"     => vpc_id,
      "CidrBlock" => cidr_block
      })

    request(:post, :create_subnet, query_params)
  end

  @doc """
  Deletes the specified subnet.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteSubnet.html
  Examples: TODO
  TODO: Parser
  """
  @type delete_subnet_opts :: [
    dry_run: boolean
  ]
  @spec delete_subnet(subnet_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec delete_subnet(subnet_id :: binary, opts :: delete_subnet_opts) :: ExAws.Operation.RestQuery.t
  def delete_subnet(subnet_id, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"SubnetId" => subnet_id})

    request(:post, :delete_subnet, query_params)
  end

  @doc """
  Modifies a subnet attribute.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifySubnetAttribute.html
  Examples: TODO
  TODO Parser
  """
  @type modify_subnet_attribute_opts :: [
    map_public_ip_on_launch: boolean,
    assign_ipv6_address_on_creation: boolean
  ]
  @spec modify_subnet_attribute(subnet_id :: binary) :: ExAws.Operation.RestQuery.t
  @spec modify_subnet_attribute(subnet_id :: binary, opts :: modify_subnet_attribute_opts) :: ExAws.Operation.RestQuery.t
  def modify_subnet_attribute(subnet_id, opts \\ []) do
    map_public_ip_on_launch = maybe_format(opts, :map_public_ip_on_launch)
    assign_ipv6_address_on_creation = maybe_format(opts, :assign_ipv6_address_on_creation)

    query_params = Enum.concat([map_public_ip_on_launch, assign_ipv6_address_on_creation])
    |> Enum.into(%{})
    |> Map.merge(%{"SubnetId" => subnet_id})

    request(:post, :modify_subnet_attribute, query_params)
  end

  ########################
  # Key Pairs Operations #
  ########################

  @doc """
  Describes one or more of your key pairs.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeKeyPairs.html
  Examples: TODO
  Parsers TODO
  """
  @type describe_key_pairs_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    key_names: [binary, ...]
  ]
  @spec describe_key_pairs() :: ExAws.Operation.RestQuery.t
  @spec describe_key_pairs(opts :: describe_key_pairs_opts) :: ExAws.Operation.RestQuery.t
  def describe_key_pairs(opts \\ []) do
    filters = maybe_format(opts, :filters)
    key_names = maybe_format(opts, :key_names)

    normalized_params = opts
      |> Keyword.delete(:filters)
      |> Keyword.delete(:key_names)
      |> normalize_opts

    query_params = Enum.concat([filters, key_names, normalized_params])
      |> Enum.into(%{})

    request(:get, :describe_key_pairs, query_params)
  end

  @doc """
  Creates a 2048-bit RSA key pair with the specified name. Amazon EC2 stores
  the public key and displays the private key for you to save to a file.
  The private key is returned as an unencrypted PEM encoded PKCS#8 private key.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateKeyPair.html

  Examples: TODO
  Parsers: TODO
  """
  @type create_key_pair_opts :: [
    dry_run: boolean
  ]
  @spec create_key_pair(key_name :: binary) :: ExAws.Operation.RestQuery.t
  @spec create_key_pair(key_name :: binary, opts :: create_key_pair_opts) :: ExAws.Operation.RestQuery.t
  def create_key_pair(key_name, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"KeyName" => key_name})

    request(:post, :create_key_pair, query_params)
  end

  @doc """
  Deletes the specified key pair, by removing the public key from Amazon EC2.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteKeyPair.html
  Examples: TODO
  Parsers: TODO
  """
  @type delete_key_pair_opts :: [
    dry_run: boolean
  ]
  @spec delete_key_pair(key_name :: binary) :: ExAws.Operation.RestQuery.t
  @spec delete_key_pair(key_name :: binary, opts :: delete_key_pair_opts) :: ExAws.Operation.RestQuery.t
  def delete_key_pair(key_name, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"KeyName" => key_name})

   request(:post, :delete_key_pair, query_params)
  end

  @doc """
  Imports the public key from an RSA key pair that you created with a
  third-party tool.

  NOTE: public_key_material is base64-encoded binary data object. The base64
  encoding is performed.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ImportKeyPair.html

  """
  @type import_key_pair_opts :: [
    dry_run: boolean
  ]
  @spec import_key_pair(key_name :: binary, public_key_material :: binary) :: ExAws.Operation.RestQuery.t
  @spec import_key_pair(key_name :: binary, public_key_material :: binary, opts :: import_key_pair_opts) :: ExAws.Operation.RestQuery.t
  def import_key_pair(key_name, public_key_material, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{
     "KeyName"           => key_name,
     "PublicKeyMaterial" => Base.url_encode64(public_key_material)
     })

    request(:post, :import_key_pair, query_params)
  end

  ##############################
  # Security Groups Operations #
  ##############################

  @type describe_security_groups_opts :: [
    dry_run: boolean,
    filters: [filter, ...],
    group_ids: [binary, ...],
    group_names: [binary, ...]
  ]
  @doc """
  Describes one or more of your security groups.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSecurityGroups.html
  """
  @spec describe_security_groups() :: ExAws.Operation.RestQuery.t
  @spec describe_security_groups(opts :: describe_security_groups_opts) :: ExAws.Operation.RestQuery.t
  def describe_security_groups(opts \\ []) do
    filters = maybe_format(opts, :filters)
    group_ids = maybe_format(opts, :group_ids)
    group_names = maybe_format(opts, :group_names)

    normalized_params = opts
      |> Keyword.delete(:filters)
      |> Keyword.delete(:group_ids)
      |> Keyword.delete(:group_names)
      |> normalize_opts

    query_params = Enum.concat([filters, group_ids, group_names, normalized_params])
    |> Enum.into(%{})

    request(:get, :describe_security_groups, query_params)
  end

  @doc """
  Creates a security group.

  Doc: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateSecurityGroup.html
  """
  @type create_security_group_opts :: [
    dry_run: boolean,
    vpc_id: binary
  ]
  @spec create_security_group(group_name :: binary, group_description :: binary) :: ExAws.Operation.RestQuery.t
  @spec create_security_group(group_name :: binary, group_description :: binary, opts :: create_security_group_opts) :: ExAws.Operation.RestQuery.t
  def create_security_group(group_name, group_description, opts \\ []) do
    query_params = opts
      |> normalize_opts
      |> Map.merge(%{
       "GroupName"        => group_name,
       "GroupDescription" => group_description
    })

    request(:post, :create_security_group, query_params)
  end


  @doc """
  Adds one or more ingress rules to a security group.
  """
  # @type authorize_security_group_ingress_opts :: [
  #   cidr_ip: binary,
  #   dry_run: boolean,
  #   from_port: integer,
  #   group_id: binary,
  #   group_name: binary,
  #   ip_permissions:
  #  {:cidr_ip, binary}                          |
  #  {:dry_run, boolean}                         |
  #  {:from_port, integer}                       |
  #  {:group_id, binary}                         |
  #  {:group_name, binary}                       |
  #  {:ip_permissions, [ip_permission]}          |
  #  {:ip_protocol, binary}                      |
  #  {:source_security_group_name, binary}       |
  #  {:source_security_group_owner_id, binary}   |
  #  {:to_port, integer}
  # ]
  # @spec authorize_security_group_ingress() :: ExAws.Operation.RestQuery.t
  # @spec authorize_security_group_ingress(opts :: authorize_security_group_ingress_opts) :: ExAws.Operation.RestQuery.t
  # def authorize_security_group_ingress(opts \\ []) do
  #  query_params = opts
  #  |> normalize_opts
  #  |> Map.merge(%{
  #    "Action"  => "AuthorizeSecurityGroupIngress",
  #    "Version" => @version
  #    })
  #
  #  request(:post, "/", query_params)
  # end
 #
 # @type authorize_security_group_egress_opts :: [
 #   {:cidr_ip, binary}                          |
 #   {:dry_run, boolean}                         |
 #   {:from_port, integer}                       |
 #   {:group_name, binary}                       |
 #   {:ip_permissions, [ip_permission]}          |
 #   {:ip_protocol, binary}                      |
 #   {:source_security_group_name, binary}       |
 #   {:source_security_group_owner_id, binary}   |
 #   {:to_port, integer}
 # ]
 # @doc """
 # Adds one or more egress rules to a security group for use with a VPC.
 # """
 # @spec authorize_security_group_egress(group_id :: binary) :: ExAws.Operation.RestQuery.t
 # @spec authorize_security_group_egress(group_id :: binary, opts :: authorize_security_group_egress_opts) :: ExAws.Operation.RestQuery.t
 # def authorize_security_group_egress(group_id, opts \\ []) do
 #   query_params = opts
 #   |> normalize_opts
 #   |> Map.merge(%{
 #     "Action"  => "AuthorizeSecurityGroupEgress",
 #     "Version" => @version,
 #     "GroupId" => group_id
 #     })
 #
 #   request(:post, "/", query_params)
 # end
 #
 # @type revoke_security_group_ingress_opts :: [
 #   {:cidr_ip, binary}                          |
 #   {:dry_run, boolean}                         |
 #   {:from_port, integer}                       |
 #   {:group_id, binary}                         |
 #   {:group_name, binary}                       |
 #   {:ip_permissions, [ip_permission]}          |
 #   {:ip_protocol, binary}                      |
 #   {:source_security_group_name, binary}       |
 #   {:source_security_group_owner_id, binary}   |
 #   {:to_port, integer}
 # ]
 # @doc """
 # Removes one or more ingress rules from a security group. The values that
 # you specify in the revoke request (for example, ports) must match
 # the existing rule's values for the rule to be removed.
 # """
 # @spec revoke_security_group_ingress() :: ExAws.Operation.RestQuery.t
 # @spec revoke_security_group_ingress(opts :: revoke_security_group_ingress_opts) :: ExAws.Operation.RestQuery.t
 # def revoke_security_group_ingress(opts \\ []) do
 #   query_params = opts
 #   |> normalize_opts
 #   |> Map.merge(%{
 #     "Action"  => "RevokeSecurityGroupIngress",
 #     "Version" => @version
 #     })
 #
 #   request(:post, "/", query_params)
 # end
 #
 # @type revoke_security_group_egress_opts :: [
 #   {:cidr_ip, binary}                          |
 #   {:dry_run, boolean}                         |
 #   {:from_port, integer}                       |
 #   {:group_name, binary}                       |
 #   {:ip_permissions, [ip_permission]}          |
 #   {:ip_protocol, binary}                      |
 #   {:source_security_group_name, binary}       |
 #   {:source_security_group_owner_id, binary}   |
 #   {:to_port, integer}
 # ]
 # @doc """
 # Removes one or more egress rules from a security group for EC2-VPC.
 # """
 # @spec revoke_security_group_egress(group_id :: binary) :: ExAws.Operation.RestQuery.t
 # @spec revoke_security_group_egress(group_id :: binary, opts :: revoke_security_group_egress_opts) :: ExAws.Operation.RestQuery.t
 # def revoke_security_group_egress(group_id, opts \\ []) do
 #   query_params = opts
 #   |> normalize_opts
 #   |> Map.merge(%{
 #     "Action"  => "RevokeSecurityGroupEgress",
 #     "Version" => @version,
 #     "GroupId" => group_id
 #     })
 #
 #   request(:post, "/", query_params)
 # end
 #

  ####################
  # Helper Functions #
  ####################
  defp request(http_method, action, params) do
    action_string = action |> Atom.to_string |> Macro.camelize
    %ExAws.Operation.RestQuery {
      http_method: http_method,
      path: "/",
      params: params |> Map.put("Action", action_string) |> Map.put("Version", @version),
      service: :ec2,
      action: action,
      parser: &ExAws.EC2.Parsers.parse/3
    }
  end

  ####################
  # Format Functions #
  ####################
  defp format_request(:assign_ipv6_address_on_creation, assign_ipv6_address_on_creation) do
    [{"AssignIpv6AddressOnCreation.Value", assign_ipv6_address_on_creation}]
  end

  defp format_request(:attribute, attribute) do
    build_indexed_params("Attribute", attribute |> Atom.to_string)
  end

  defp format_request(:attribute_names, attribute_names) do
    modified_attribute_names = for attribute_name <- attribute_names do
      attribute_name
      |> Atom.to_string
      |> String.replace("_", "-")
    end

    build_indexed_params("AttributeName", modified_attribute_names)
  end

  defp format_request(:bundle_ids, bundle_ids) do
    build_indexed_params("BundleId", bundle_ids)
  end

  defp format_request(:enable_dns_hostnames, enable_dns_hostnames) do
    [{"EnableDnsHostnames.Value", enable_dns_hostnames}]
  end

  defp format_request(:enable_dns_support, enable_dns_support) do
    [{"EnableDnsSupport.Value", enable_dns_support}]
  end

  defp format_request(:executable_by_list, executable_by_list) do
    build_indexed_params("ExecutableBy", executable_by_list)
  end

  defp format_request(:filters, filters) do
    filters = for{name, values} <- filters,
      do: [name: maybe_stringify(name), value: values]

    build_indexed_params("Filter", filters)
  end

  defp format_request(:group_ids, group_ids) do
    build_indexed_params("GroupId", group_ids)
  end

  defp format_request(:group_names, group_names) do
    build_indexed_params("GroupName", group_names)
  end

  defp format_request(:image_ids, image_ids) do
    build_indexed_params("ImageId", image_ids)
  end

  defp format_request(:instance_ids, instance_ids) do
    build_indexed_params("InstanceId", instance_ids)
  end

  defp format_request(:instance_tenancy, instance_tenancy) do
    [{"InstanceTenancy", instance_tenancy |> Atom.to_string}]
  end

  defp format_request(:key_names, key_names) do
    build_indexed_params("KeyName", key_names)
  end

  defp format_request(:map_public_ip_on_launch, map_public_ip_on_launch) do
    [{"MapPublicIpOnLaunch.Value", map_public_ip_on_launch}]
  end

  defp format_request(:owners, owners) do
    build_indexed_params("Owner", owners)
  end

  defp format_request(:region_names, region_names) do
    build_indexed_params("RegionName", region_names)
  end

  defp format_request(:resource, resource) do
    [{"Resource",
      resource
        |> Atom.to_string
    }]
  end

  defp format_request(:resource_ids, resource_ids) do
    build_indexed_params("ResourceId", resource_ids)
  end

  defp format_request(:subnet_ids, subnet_ids) do
    build_indexed_params("SubnetId", subnet_ids)
  end

  defp format_request(:user_groups, user_groups) do
    build_indexed_params("UserGroup", user_groups)
  end

  defp format_request(:user_ids, user_ids) do
    build_indexed_params("UserId", user_ids)
  end

  defp format_request(:vpc_ids, vpc_ids) do
    build_indexed_params("VpcId", vpc_ids)
  end

  defp format_request(:tags, tags) do
    tags = for {key, value} <- tags, do: [key: Atom.to_string(key), value: value]

    build_indexed_params("Tag", tags)
    |> filter_nil_params
  end

  defp format_request(:create_permission_modifications, create_permission_modifications) do
    create_permission_modifications = for{}
  end

  defp format_request(:tag_specifications, tag_specs) do
    tag_specs = for {resource_type, tags} <- tag_specs do
      [resource_type: Atom.to_string(resource_type),
       tag: for {key, value} <- tags do [key: Atom.to_string(key), value: value] end]
    end

    build_indexed_params("TagSpecification", tag_specs)
    |> filter_nil_params
  end


  defp format_request(:volume_type, volume_type) do
    [{"VolumeType", volume_type |> Atom.to_string}]
  end

  defp format_request(:zone_names, zone_names) do
    build_indexed_params("ZoneName", zone_names)
  end
end
