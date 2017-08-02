defmodule ExAws.ElastiCache.ParserTest do
  use ExUnit.Case, async: true
  alias ExAws.ElastiCache.Parsers

  def to_success(doc) do
    {:ok, %{body: doc}}
  end

  test "parsing create_cache_cluster response" do
    rsp = """
    <CreateCacheClusterResponse xmlns="http://elasticache.amazonaws.com/doc/2015-02-02/">
      <CreateCacheClusterResult>
        <CacheCluster>
          <CacheClusterId>russherm-api-test</CacheClusterId>
          <CacheClusterStatus>creating</CacheClusterStatus>
          <CacheParameterGroup>
            <CacheParameterGroupName>default.memcached1.4</CacheParameterGroupName>
            <ParameterApplyStatus>in-sync</ParameterApplyStatus>
            <CacheNodeIdsToReboot/>
          </CacheParameterGroup>
          <CacheNodeType>cache.m1.small</CacheNodeType>
          <Engine>memcached</Engine>
          <PendingModifiedValues/>
          <EngineVersion>1.4.14</EngineVersion>
          <AutoMinorVersionUpgrade>true</AutoMinorVersionUpgrade>
          <PreferredMaintenanceWindow>sat:09:00-sat:10:00</PreferredMaintenanceWindow>
          <ClientDownloadLandingPage>https://console.aws.amazon.com/elasticache/home#client-download:</ClientDownloadLandingPage>
          <CacheSecurityGroups>
            <CacheSecurityGroup>
              <CacheSecurityGroupName>default</CacheSecurityGroupName>
              <Status>active</Status>
            </CacheSecurityGroup>
          </CacheSecurityGroups>
          <NumCacheNodes>3</NumCacheNodes>
        </CacheCluster>
      </CreateCacheClusterResult>
      <ResponseMetadata>
        <RequestId>69134921-10f9-11e4-81bb-d76bad68b8fd</RequestId>
      </ResponseMetadata>
    </CreateCacheClusterResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :create_cache_cluster, nil)
    cluster = parsed_doc[:cache_cluster]
    assert cluster[:cache_cluster_id] == "russherm-api-test"
    assert cluster[:engine] == "memcached"

    [security_group] = cluster[:cache_security_groups]
    assert security_group[:cache_security_group_name] == "default"
    assert security_group[:status] == "active"

    assert parsed_doc[:request_id] == "69134921-10f9-11e4-81bb-d76bad68b8fd"
  end

  test "parsing delete_cache_cluster response" do
    rsp = """
    <DeleteCacheClusterResponse xmlns="http://elasticache.amazonaws.com/doc/2015-02-02/">
      <DeleteCacheClusterResult>
        <CacheCluster>
          <CacheParameterGroup>
            <ParameterApplyStatus>in-sync</ParameterApplyStatus>
            <CacheParameterGroupName>default.memcached1.4</CacheParameterGroupName>
            <CacheNodeIdsToReboot/>
          </CacheParameterGroup>
          <CacheClusterId>simcoprod43</CacheClusterId>
          <CacheClusterStatus>deleting</CacheClusterStatus>
          <ConfigurationEndpoint>
            <Port>11211</Port>
            <Address>simcoprod43.m2st2p.cfg.cache.amazonaws.com</Address>
          </ConfigurationEndpoint>
          <CacheNodeType>cache.m1.large</CacheNodeType>
          <Engine>memcached</Engine>
          <PendingModifiedValues/>
          <PreferredAvailabilityZone>us-west-2b</PreferredAvailabilityZone>
          <CacheClusterCreateTime>2015-02-02T02:18:26.497Z</CacheClusterCreateTime>
          <EngineVersion>1.4.5</EngineVersion>
          <AutoMinorVersionUpgrade>true</AutoMinorVersionUpgrade>
          <PreferredMaintenanceWindow>mon:05:00-mon:06:00</PreferredMaintenanceWindow>
          <CacheSecurityGroups>
            <CacheSecurityGroup>
              <CacheSecurityGroupName>default</CacheSecurityGroupName>
              <Status>active</Status>
            </CacheSecurityGroup>
          </CacheSecurityGroups>
          <NumCacheNodes>3</NumCacheNodes>
        </CacheCluster>
      </DeleteCacheClusterResult>
      <ResponseMetadata>
        <RequestId>ab84aa7e-b7fa-11e0-9b0b-a9261be2b354</RequestId>
      </ResponseMetadata>
    </DeleteCacheClusterResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :delete_cache_cluster, nil)
    cluster = parsed_doc[:cache_cluster]
    assert cluster[:engine_version] == "1.4.5"
    assert cluster[:auto_minor_version_upgrade] == "true"

    cache_parameter_group = cluster[:cache_parameter_group]
    assert cache_parameter_group[:parameter_apply_status] == "in-sync"
    assert cache_parameter_group[:cache_parameter_group_name] == "default.memcached1.4"

    assert parsed_doc[:request_id] == "ab84aa7e-b7fa-11e0-9b0b-a9261be2b354"
  end

  test "parsing describe_cache_cluster response" do
    rsp = """
    <DescribeCacheClustersResponse xmlns="http://elasticache.amazonaws.com/doc/2015-02-02/">
      <DescribeCacheClustersResult>
        <CacheClusters>
          <CacheCluster>
            <CacheParameterGroup>
              <ParameterApplyStatus>in-sync</ParameterApplyStatus>
              <CacheParameterGroupName>default.memcached1.4</CacheParameterGroupName>
              <CacheNodeIdsToReboot/>
            </CacheParameterGroup>
            <CacheClusterId>simcoprod42</CacheClusterId>
            <CacheClusterStatus>available</CacheClusterStatus>
            <ConfigurationEndpoint>
              <Port>11211</Port>
              <Address>simcoprod42.m2st2p.cfg.cache.amazonaws.com</Address>
            </ConfigurationEndpoint>
            <ClientDownloadLandingPage>https://console.aws.amazon.com/elasticache/home#client-download:</ClientDownloadLandingPage>
            <CacheNodeType>cache.m1.large</CacheNodeType>
            <Engine>memcached</Engine>
            <PendingModifiedValues/>
            <PreferredAvailabilityZone>us-west-2c</PreferredAvailabilityZone>
            <CacheClusterCreateTime>2015-02-02T01:21:46.607Z</CacheClusterCreateTime>
            <EngineVersion>1.4.5</EngineVersion>
            <AutoMinorVersionUpgrade>true</AutoMinorVersionUpgrade>
            <PreferredMaintenanceWindow>fri:08:30-fri:09:30</PreferredMaintenanceWindow>
            <CacheSecurityGroups>
              <CacheSecurityGroup>
                <CacheSecurityGroupName>default</CacheSecurityGroupName>
                <Status>active</Status>
              </CacheSecurityGroup>
            </CacheSecurityGroups>
            <NotificationConfiguration>
              <TopicStatus>active</TopicStatus>
              <TopicArn>arn:aws:sns:us-west-2:123456789012:ElastiCacheNotifications</TopicArn>
            </NotificationConfiguration>
            <NumCacheNodes>6</NumCacheNodes>
          </CacheCluster>
        </CacheClusters>
      </DescribeCacheClustersResult>
      <ResponseMetadata>
        <RequestId>f270d58f-b7fb-11e0-9326-b7275b9d4a6c</RequestId>
      </ResponseMetadata>
    </DescribeCacheClustersResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :describe_cache_clusters, nil)
    [cluster] = parsed_doc[:cache_clusters]
    assert cluster[:cache_cluster_id] == "simcoprod42"
    assert cluster[:client_download_landing_page] == "https://console.aws.amazon.com/elasticache/home#client-download:"

    configuration_endpoint = cluster[:configuration_endpoint]
    assert configuration_endpoint[:port] == "11211"
    assert configuration_endpoint[:address] == "simcoprod42.m2st2p.cfg.cache.amazonaws.com"

    assert cluster[:num_cache_nodes] == "6"
    assert parsed_doc[:request_id] == "f270d58f-b7fb-11e0-9326-b7275b9d4a6c"
  end
end
