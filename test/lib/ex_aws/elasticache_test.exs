defmodule ExAws.ElastiCacheTest do
  use ExUnit.Case, async: true
  doctest ExAws.ElastiCache

  alias ExAws.ElastiCache

  @version "2015-02-02"

  defp build_query(action, params \\ %{}) do
    action_string =
      action
      |> Atom.to_string
      |> Macro.camelize

    %ExAws.Operation.Query{
      path: "/",
      params: params |> Map.merge(%{"Version" => @version, "Action" => action_string}),
      service: :elasticache,
      action: action,
      parser: &ExAws.ElastiCache.Parsers.parse/3
    }
  end

  test "create_cache_cluster no options" do
    expected = build_query(:create_cache_cluster, %{
      "CacheClusterId" => "myMemcachedCluster",
      "CacheNodeType" => "cache.m1.small",
      "Engine" => "memcached",
      "NumCacheNodes" => 3
      })

    assert expected == ElastiCache.create_cache_cluster("myMemcachedCluster", "cache.m1.small", "memcached", 3)
  end

  test "create_cache_cluster with list params" do
    expected = build_query(:create_cache_cluster, %{
      "CacheClusterId" => "myMemcachedCluster",
      "CacheNodeType" => "cache.m1.small",
      "Engine" => "memcached",
      "NumCacheNodes" => 3,
      "CacheSecurityGroupNames.CacheSecurityGroupName.1" => "securityGroup1",
      "CacheSecurityGroupNames.CacheSecurityGroupName.2" => "securityGroup2",
      "PreferredMaintenanceWindow" => "sun:23:00-mon:01:30",
      "PreferredAvailabilityZones.PreferredAvailabilityZone.1" => "us-east-1",
      "PreferredAvailabilityZones.PreferredAvailabilityZone.2" => "us-east-2",
      "SnapshotArns.SnapshotArn.1" => "arn:aws:s3:::my_bucket/snapshot1.rdb",
      "SnapshotArns.SnapshotArn.2" => "arn:aws:s3:::my_bucket/snapshot2.rdb"
      })

    assert expected == ElastiCache.create_cache_cluster("myMemcachedCluster", "cache.m1.small", "memcached", 3,
      [cache_security_group_names: ["securityGroup1", "securityGroup2"],
       preferred_maintenance_window: "sun:23:00-mon:01:30",
       preferred_availability_zones: ["us-east-1", "us-east-2"],
       snapshot_arns: ["arn:aws:s3:::my_bucket/snapshot1.rdb", "arn:aws:s3:::my_bucket/snapshot2.rdb"]
      ]
    )
  end

  test "delete_cache_cluster no options" do
    expected = build_query(:delete_cache_cluster, %{
      "CacheClusterId" => "myMemcachedCluster"
      })

    assert expected == ElastiCache.delete_cache_cluster("myMemcachedCluster")
  end


  test "delete_cache_cluster with params" do
    expected = build_query(:delete_cache_cluster, %{
      "CacheClusterId" => "myMemcachedCluster",
      "FinalSnapshotIdentifier" => "memcachedTestSnapshot"
      })
    assert expected == ElastiCache.delete_cache_cluster("myMemcachedCluster",
    [final_snapshot_identifier: "memcachedTestSnapshot"])
  end

  test "describe_cache_clusters no options" do
    expected = build_query(:describe_cache_clusters, %{})

    assert expected == ElastiCache.describe_cache_clusters
  end

  test "describe_cache_clusters with params" do
    expected = build_query(:describe_cache_clusters,
      %{"CacheClusterId" => "simcoprod42",
        "Marker" => "TestMarker",
        "MaxRecords" => 100,
        "ShowCacheClustersNotInReplicationGroups" => true,
        "ShowCacheNodeInfo" => true})

    assert expected == ElastiCache.describe_cache_clusters([
      cache_cluster_id: "simcoprod42",
      marker: "TestMarker",
      max_records: 100,
      show_cache_clusters_not_in_replication_groups: true,
      show_cache_node_info: true])
  end
end
