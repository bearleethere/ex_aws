if Code.ensure_loaded(SweetXml) do
  defmodule ExAws.ElastiCache.Parsers do
    import SweetXml

    def parse({:ok, %{body: xml}=resp}, :create_cache_cluster, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//CreateCacheClusterResponse",
        request_id: request_id_xpath(),
        cache_cluster: [
          ~x"./CreateCacheClusterResult/CacheCluster",
        ] ++ cache_cluster_fields
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :delete_cache_cluster, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//DeleteCacheClusterResponse",
        request_id: request_id_xpath(),
        cache_cluster: [
          ~x"./DeleteCacheClusterResult/CacheCluster",
        ] ++ cache_cluster_fields ++ configuration_endpoint_fields
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :describe_cache_clusters, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//DescribeCacheClustersResponse",
        request_id: request_id_xpath(),
        cache_clusters: [
          ~x"./DescribeCacheClustersResult/CacheClusters/CacheCluster"l,
          cache_cluster_create_time: ~x"./CacheClusterCreateTime/text()"s,
          notification_configuration: [
            ~x"./NotificationConfiguration",
            topic_status: ~x"./TopicStatus/text()"s,
            topic_arn: ~x"./TopicArn/text()"s
          ]
        ] ++ cache_cluster_fields ++ configuration_endpoint_fields
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    defp request_id_xpath do
      ~x"./ResponseMetadata/RequestId/text()"s
    end

    defp cache_cluster_fields do
      [
        cache_parameter_group: [
          ~x"./CacheParameterGroup",
          parameter_apply_status: ~x"./ParameterApplyStatus/text()"s,
          cache_parameter_group_name: ~x"./CacheParameterGroupName/text()"s,
          cache_node_ids_to_reboot: ~x"./CacheNodeIdsToReboot/text()"s
        ],
        cache_cluster_id: ~x"./CacheClusterId/text()"s,
        cache_cluster_status: ~x"./CacheClusterStatus/text()"s,
        client_download_landing_page: ~x"./ClientDownloadLandingPage/text()"s,
        cache_node_type: ~x"./CacheNodeType/text()"s,
        engine: ~x"./Engine/text()"s,
        preferred_availability_zone: ~x"./PreferredAvailabilityZonev"s,
        engine_version: ~x"./EngineVersion/text()"s,
        auto_minor_version_upgrade: ~x"./AutoMinorVersionUpgrade/text()"s,
        preferred_maintenance_window: ~x"./PreferredMaintenanceWindow/text()"s,
        cache_security_groups: [
          ~x"./CacheSecurityGroups/CacheSecurityGroup"lo,
          cache_security_group_name: ~x"./CacheSecurityGroupName/text()"s,
          status: ~x"./Status/text()"s
        ],
        num_cache_nodes: ~x"./NumCacheNodes/text()"s
      ]
    end

    defp configuration_endpoint_fields do
      [
        configuration_endpoint: [
          ~x"./ConfigurationEndpoint",
          port: ~x"./Port/text()"s,
          address: ~x"./Address/text()"s
        ]
      ]
    end
  end
end
