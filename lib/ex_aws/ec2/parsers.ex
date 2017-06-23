if Code.ensure_loaded(SweetXml) do
  defmodule ExAws.EC2.Parsers do
    import SweetXml

    defp code_xpath do
      ~x"./code/text()"s
    end

    defp code_name_fields() do
      [
        code: code_xpath(),
        name: ~x"./name/text()"s
      ]
    end

    defp current_previous_state_fields() do
      [
        current_state: [
          ~x"./currentState",
        ] ++ code_name_fields(),
        previous_state: [
          ~x"./previousState",
        ] ++ code_name_fields()
      ]
    end

    defp instance_id_xpath do
      ~x"./instanceId/text()"s
    end

    defp details_fields do
      [
        details: [
          ~x"./details/item"l,
          name: ~x"./name/text()"s,
          status: ~x"./status/text()"s,
          impaired_since: ~x"./impairedSince/text()"s
        ]
      ]
    end

    defp status_xpath do
      ~x"./status/text()"s
    end

    defp attach_detach_volume_fields do
      [
        request_id: request_id_xpath(),
        volume_id: ~x"./volumeId/text()"s,
        instance_id: ~x"./instanceId/text()"s,
        device: ~x"./device/text()"s,
        status: status_xpath(),
        attach_time: ~x"./attachTime/text()"s
      ]
    end

    def parse({:ok, %{body: xml}=resp}, :terminate_instances, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//TerminateInstancesResponse",
        request_id: request_id_xpath(),
        instances: [
          ~x"./instancesSet/item"l,
          instance_id: instance_id_xpath(),
        ] ++ current_previous_state_fields())

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :reboot_instances, _) do
      parsed_body = xml
        |> SweetXml.xpath(~x"//RebootInstancesResponse",
        request_id: request_id_xpath(),
        return: ~x"./return/text()"s
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :start_instances, _) do
      parsed_body = xml
        |> SweetXml.xpath(~x"//StartInstancesResponse",
        request_id: request_id_xpath(),
        instances: [
          ~x"./instancesSet/item"l,
          instance_id: instance_id_xpath(),
        ] ++ current_previous_state_fields())

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :stop_instances, _) do
      parsed_body = xml
        |> SweetXml.xpath(~x"//StopInstancesResponse",
        request_id: request_id_xpath(),
        instances: [
          ~x"./instancesSet/item"l,
          instance_id: instance_id_xpath(),
        ] ++ current_previous_state_fields())

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :describe_instances, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//DescribeInstancesResponse",
        request_id: request_id_xpath(),
        reservations: [
          ~x"./reservationSet/item"l,
          reservation_id: ~x"./reservationId/text()"s,
          owner_id: ~x"./ownerId/text()"s,
          instances: [
            ~x"./instancesSet/item"l,
            instance_id: instance_id_xpath(),
            image_id: ~x"./imageId/text()"s,
            state: [
              ~x"./instanceState",
            ] ++ code_name_fields(),
            private_dns_name: ~x"./privateDnsName/text()"s,
            public_dns_name: ~x"./dnsName/text()"s,
            key_name: ~x"./keyName/text()"s,
            ami_launch_index: ~x"./amiLaunchIndex/text()"s,
            product_codes: [
              ~x"./product_codes"lo,
              product_code: ~x"./productCode/text()"s,
              type: ~x"./type/text()"s
            ],
            instance_type: ~x"./instanceType/text()"s,
            launch_time: ~x"./launchTime/text()"s,
            placement: [
              ~x"./placement"o,
              availability_zone: ~x"./availabilityZone/text()"s,
              group_name: ~x"./groupName/text()"s,
              tenancy: ~x"./tenancy/text()"s
            ],
            monitoring: [
              ~x"./monitoring"o,
              state: ~x"./state/text()"s
            ],
            subnet_id: ~x"./subnetId/text()"s,
            vpc_id: ~x"./vpcId/text()"s,
            private_ip_address: ~x"./privateIpAddress/text()"s,
            public_ip_address: ~x"./ipAddress/text()"s,
            state_reason: ~x"./reason/text()"s,
            source_destination_check: ~x"./sourceDestCheck/text()"s,
            security_groups: [
              ~x"./groupSet/item"l,
              group_id: ~x"./groupId/text()"s,
              group_name: ~x"./groupName/text()"s
            ],
            architecture: ~x"./architecture/text()"s,
            root_device_type: ~x"./rootDeviceType/text()"s,
            root_device_name: ~x"./rootDeviceName/text()"s,
            block_device_mapping: [
              ~x"./blockDeviceMapping/item"l,
              device_name: ~x"./deviceName/text()"s,
              ebs: [
                ~x"./ebs"o,
                volume_id: ~x"./volumeId/text()"s,
                status: ~x"./status/text()"s,
                attach_time: ~x"./attachTime/text()"s,
                delete_on_termination: ~x"./deleteOnTermination/text()"s
              ],
            ],
            virtualization_type: ~x"./hvm/text()"s,
            client_token: ~x"./clientToken/text()"s,
            tags: [
              ~x"./tagSet/item"l,
              key: ~x"./key/text()"s,
              value: ~x"./value/text()"s
            ],
            hypervisor: ~x"./hypervisor/text()"s,
            network_interfaces: [
              ~x"./networkInterfaceSet/item"l,
              network_interface_id: ~x"./networkInterfaceId/text()"s,
              subnet_id: ~x"./subnetId/text()"s,
              vpc_id: ~x"./vpcId/text()"s,
              description: ~x"./description/text()"s,
              owner_id: ~x"./ownerId/text()"s,
              status: ~x"./status/text()"s,
              mac_address: ~x"./macAddress/text()"s,
              private_ip_address: ~x"./privateIpAddress/text()"s,
              private_dns_name: ~x"./privateDnsName/text()"s,
              source_destination_check: ~x"./sourceDestCheck/text()"s,
              security_groups: [
                ~x"./groupSet/item"l,
                group_id: ~x"./groupId/text()"s,
                group_name: ~x"./groupName/text()"s
              ],
              attachment: [
                ~x"./attachment"o,
                attachment_id: ~x"./attachmentId/text()"s,
                device_index: ~x"./deviceIndex/text()"s,
                status: ~x"./status/text()"s,
                attachTime: ~x"./attachTime/text()"s,
                delete_on_termination: ~x"./deleteOnTermination/text()"s
              ],
              association: [
                ~x"./association"o,
                public_ip: ~x"./publicIp/text()"s,
                public_dns_name: ~x"./publicDnsName/text()"s,
                ip_owner_id: ~x"./ipOwnerId/text()"s
              ],
              private_ip_addresses: [
                ~x"./privateIpAddressesSet/item"l,
                private_ip: ~x"./privateIpAddress/text()"s,
                private_dns_name: ~x"./privateDnsName/text()"s,
                primary: ~x"./primary/text()"s,
                association: [
                  ~x"./association"o,
                  public_ip: ~x"./publicIp/text()"s,
                  public_dns_name: ~x"./publicDnsName/text()"s,
                  ip_owner_id: ~x"./ipOwnerId/text()"s
                ],
              ],
              ipv6_addresses: [
                ~x"./ipv6AddressesSet/item"l,
                ipv6_address: ~x"./ipv6Address/text()"s
              ],
            ],
            ebs_optimized: ~x"./ebsOptimized/text()"s
          ]
        ])

        {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :describe_instance_status, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//DescribeInstanceStatusResponse",
        request_id: request_id_xpath(),
        instances_statuses: [
          ~x"./instanceStatusSet/item"l,
          instance_id: ~x"./instanceId/text()"s,
          availability_zone: ~x"./availabilityZone/text()"s,
          state: [
            ~x"./instanceState",
          ] ++ code_name_fields(),
          system_status: [
            ~x"./systemStatus",
            status: status_xpath(),
          ] ++ details_fields(),
          instance_status: [
            ~x"./instanceStatus",
            status: status_xpath(),
          ] ++ details_fields(),
          events: [
            ~x"./eventsSet/item"l,
            code: code_xpath(),
            description: ~x"./description/text()"s,
            not_before_date: ~x"./notBefore/text()"s,
            not_after_date: ~x"./notAfter/text()"s
          ]
        ])

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :attach_volume, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//AttachVolumeResponse",
        [] ++ attach_detach_volume_fields()
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :detach_volume, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//DetachVolumeResponse",
        [] ++ attach_detach_volume_fields()
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :create_volume, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//CreateVolumeResponse",
        request_id: request_id_xpath(),
        volume_id: ~x"./volumeId/text()"s,
        size: ~x"./size/text()"s,
        snapshot_id: ~x"./snapshotId/text()"s,
        availability_zone: ~x"./availabilityZone/text()"s,
        status: ~x"./status/text()"s,
        create_time: ~x"./createTime/text()"s,
        volume_type: ~x"./volumeType/text()"s,
        encrypted: ~x"./encrypted/text()"s
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    # WTF Amazon. "return" in the XML???
    def parse({:ok, %{body: xml}=resp}, :delete_volume, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//DeleteVolumeResponse",
        request_id: request_id_xpath(),
        return: ~x"./return/text()"s
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :modify_volume, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//ModifyVolumeResponse",
        request_id: request_id_xpath(),
        target_iops: ~x"./volumeModification/targetIops/text()"s,
        original_iops: ~x"./volumeModification/originalIops/text()"s,
        modification_state: ~x"./volumeModification/modificationState/text()"s,
        target_size: ~x"./volumeModification/targetSize/text()"s,
        target_volume_type: ~x"./volumeModification/targetVolumeType/text()"s,
        volume_id: ~x"./volumeModification/volumeId/text()"s,
        progress: ~x"./volumeModification/progress/text()"s,
        start_time: ~x"./volumeModification/startTime/text()"s,
        original_size: ~x"./volumeModification/originalSize/text()"s,
        original_volume_type: ~x"./volumeModification/originalVolumeType/text()"s
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:error, {type, http_status_code, %{body: xml}}}, _, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//Response",
            code: ~x"./Errors/Error/Code/text()"s,
            message: ~x"./Errors/Error/Message/text()"s,
            request_id: ~x"./RequestID/text()"s)

      {:error, {type, http_status_code, parsed_body}}
    end

    defp request_id_xpath do
      ~x"./requestId/text()"s
    end
  end
end
