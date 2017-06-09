defmodule ExAws.Cloudformation do
  @moduledoc """
  Operations on Cloudformation

  ## Basic Usage
  ```elixir
  alias ExAws.Cloudformation

  # Create a stack with name with parameters
  Cloudformation.create_stack("name",
  [parameters:
      [parameter_key: "AvailabilityZone", parameter_value: "us-east-1"],
      [parameter_key: "InstanceType", "parameter_value: "m1.micro"]
  ]) |> ExAws.request!

  # Delete a stack
  Cloudformation.delete_stack("name", [role_arn: "aws:iam::blah:role/god"])
  |> ExAws.request(region: "us-east-1")
  ```
  ## General notes
  All options are handled as underscore_atoms instead of camelcased binaries as specified
  in the CloudFormation API, I.E ':role_arn' would be 'RoleARN'.

  http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_Operations.html
  """

  import ExAws.Utils

  @version "2010-05-15"

  @type accepted_capability_vals ::
    :capability_iam |
    :capability_named_iam


  @type on_failure_vals ::
    :do_nothing |
    :rollback |
    :delete

  @type parameter :: [
    parameter_key: binary,
    parameter_value: binary,
    use_previous_value: boolean
  ]

  @type tag :: {key :: atom, value :: binary}


  @doc """
  Cancels an update on the specified stack.

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CancelUpdateStack.html

  Examples:
  ```
  Cloudformation.cancel_update_stack("Test")
  ```
  """
  @spec cancel_update_stack(stack_name :: binary) :: ExAws.Operation.Query.t
  def cancel_update_stack(stack_name) do
    request(:cancel_update_stack, %{"StackName" => stack_name})
  end


  @doc """
  Rollbacks a stack in UPDATE_ROLLBACK_FAILED state until the state changes to
  UPDATE_ROLLBACK_COMPLETE state.

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_ContinueUpdateRollback.html

  Examples:
  ```
  Cloudformation.continue_update_rollback("Test", [role_arn: "aws:iam:test"])

  Cloudformation.continue_update_rollback("test_stack", [skip_resources: ["test_resource_1", "test_resource_2"]])

  Cloudformation.continue_update_rollback("test_stack", [role_arn: "arn:my:thing", skip_resources: ["test_resource_1", "test_resource_2"]]
  ```
  """
  @type continue_update_rollback_opts :: [
    role_arn: binary,
    skip_resources: [binary, ...]
  ]

  @spec continue_update_rollback(stack_name :: binary, opts :: continue_update_rollback_opts) :: ExAws.Operation.Query.t
  def continue_update_rollback(stack_name, opts \\ []) do
    skip_resources = maybe_transform(:transform_skip_resources, opts[:skip_resources])

    query_params =
      Enum.concat([skip_resources,
      [{"RoleARN", opts[:role_arn]}, {"StackName", stack_name}]])
      |> filter_nil_params

    request(:continue_update_rollback, query_params)
  end

  # key :: atom
  # These parameters either has a list that needs transformed to the kind of
  # parameters AWS is using or simply camelizing them does not work.
  @params_to_delete [
    :capabilities,
    :parameters,
    :notification_arns,
    :tags,
    :resource_types,
    :template_url,
    :role_arn,
    :status_filter
  ]

  # {key :: atom, transform_function_name :: atom}
  @params_to_transform [
    {:capabilities, :transform_capabilities},
    {:parameters, :transform_parameters},
    {:notification_arns, :transform_notification_arns},
    {:tags, :transform_tags},
    {:resource_types, :transform_resource_types}
  ]

  @doc """
  Creates a stack as specified in a template.

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html

  Examples:
  ```
  # Create stack from a template url
  Cloudformation.create_stack("stack_name", [template_url: "https://s3.amazonaws.com/sample.json"])

  # Create stack with parameters
  Cloudformation.create_stack("test_stack",
  [parameters: [[parameter_key: "AvailabilityZone", parameter_value: "us-east-1a"],
  [parameter_key: "InstanceType", parameter_value: "m1.micro"]]])
  ```
  """
  @type create_stack_opts :: [
    capabilities: [accepted_capability_vals, ...],
    disable_rollback: boolean,
    notification_arns: [binary, ...],
    on_failure: on_failure_vals,
    parameters: [parameter, ...],
    resource_types: [binary, ...],
    role_arn: binary,
    stack_policy_body: binary,
    stack_policy_url: binary,
    tags: [tag, ...],
    template_body: binary,
    template_url: binary,
    timeout_in_minutes: integer
  ]

  @spec create_stack(stack_name :: binary, opts :: create_stack_opts) :: ExAws.Operation.Query.t
  def create_stack(stack_name, opts \\ []) do
    normal_params = opts
    |> Enum.reject(fn {key, _} -> key in @params_to_delete end)
    |> normalize_opts

    transformed_params = @params_to_transform
    |> Enum.flat_map(fn {key, transform_func} ->
      maybe_transform(transform_func, opts[key])
    end)

    other_params = [{"StackName", stack_name}, {"TemplateURL", opts[:template_url]}, {"RoleARN", opts[:role_arn]}]

    query_params =
      Enum.concat([normal_params, transformed_params, other_params])
      |> filter_nil_params

    request(:create_stack, query_params)
  end


  @doc """
  Deletes a stack

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DeleteStack.html

  Examples:
  ```

  # Deletes a stack
  Cloudformation.delete_stack("stack_name")

  # Deletes a stack by stack name with a RoleARN
  Cloudformation.delete_stack("stack_name", [role_arn: "aws:iam:123456:role/test"])

  # Deletes a stack except for a couple of resources
  Cloudformation.delete_stack("stack_name", [retain_resources: ["test_resource_1", "test_resource_2"]])
  ```
  """
  @type delete_stack_opts :: [
    retain_resources: [binary, ...],
    role_arn: binary
  ]
  @spec delete_stack(stack_name :: binary, opts :: delete_stack_opts) :: ExAws.Operation.Query.t
  def delete_stack(stack_name, opts \\ []) do
    transformed_retain_resources = maybe_transform(:transform_retain_resources, opts[:retain_resources])

    query_params = Enum.concat([transformed_retain_resources, [{"StackName", stack_name}, {"RoleARN", opts[:role_arn]}]])
    |> filter_nil_params

    request(:delete_stack, query_params)
  end

  @doc """
  Describes a specified stack's resource.
  Resource of the stack is specified by a logical record ID.

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStackResource.html

  Examples:
  ```
  Cloudformation.describe_stack_resource("Test", "logical_resource_Id")
  ```
  """
  @spec describe_stack_resource(stack_name :: binary, logical_resource_id :: binary) :: ExAws.Operation.Query.t
  def describe_stack_resource(stack_name, logical_resource_id) do
    query_params = %{
      "StackName" => stack_name,
      "LogicalResourceId" => logical_resource_id
    }

    request(:describe_stack_resource, query_params)
  end


  @doc """
  Describes specified stack's resources. You either have to specify a stack name
  or a physical resource ID.

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStackResources.html

  Example:
  ```
  #Describe resources by stack name
  Cloudformation.describe_stack_resources([stack_name: "Test"])

  #Describe resources with a logical resource ID
  Cloudformation.describe_stack_resources([stack_name: "Test", logical_resource_id: "test_resource_id"])

  #Describe resources with a physical resource ID
  Cloudformation.describe_stack_resources([physical_resource_id: "test_resource_id"])
  ```
  """
  @type describe_stack_resources_opts :: [
    stack_name: binary,
    logical_resource_id: binary,
    physical_resource_id: binary
  ]
  @spec describe_stack_resources(opts :: describe_stack_resources_opts) :: ExAws.Operation.Query.t
  def describe_stack_resources(opts \\ []) do
    request(:describe_stack_resources, normalize_opts(opts))
  end


  @doc """
  Gets the summary information for stacks. If no :stack_status_filters are passed in,
  then all stacks are returned (existing and stacks have have been deleted in the last 90 days)

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_ListStacks.html

  Examples:
  ```
  # List all stacks
  Cloudformation.list_stacks

  #List stacks with some stack status filters
  Cloudformation.list_stacks([stack_status_filters: [:delete_complete]])
  ```
  """
  @type list_stacks_opts :: [
    next_token: binary,
    stack_status_filters: [ExAws.Cloudformation.Parsers.stack_status, ...]
  ]
  @spec list_stacks(opts :: list_stacks_opts) :: ExAws.Operation.Query.t
  def list_stacks(opts \\ []) do
    transformed_stack_status_filters = maybe_transform(:transform_stack_status_filters, opts[:stack_status_filters])

    query_params =
      Enum.concat([transformed_stack_status_filters,
      [{"Next_Token", opts[:next_token]}]])
      |> filter_nil_params

    request(:list_stacks, query_params)
  end

  @doc """
  Lists summary of all of the resources for a specified stack

  Please read: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_ListStackResources.html

  Examples:
  ```
  Cloudformation.list_stack_resources("test_stack")

  Cloudformation.list_stack_resources("test_stack", [next_token: "token"])
  ```
  """
  @spec list_stack_resources(stack_name :: binary, opts :: [next_token: binary]) :: ExAws.Operation.Query.t
  def list_stack_resources(stack_name, opts \\ []) do
    query_params = opts
    |> normalize_opts
    |> Map.merge(%{"StackName" => stack_name})

    request(:list_stack_resources, query_params)
  end

  ########################
  ### Helper Functions ###
  ########################

  defp request(action, params) do
    action_string = action |> Atom.to_string |> Macro.camelize

    %ExAws.Operation.Query{
      path: "/",
      params: params |> Map.put("Action", action_string) |> Map.put("Version", @version),
      service: :cloudformation,
      action: action,
      parser: &ExAws.Cloudformation.Parsers.parse/3
    }
  end

  defp filter_nil_params(opts) do
    opts
    |> Enum.reject(fn {_key, value} -> value == nil end)
    |> Enum.into(%{})
  end

  defp normalize_opts(opts) do
    opts
    |> Enum.into(%{})
    |> camelize_keys
  end

  def transform_skip_resources(resources) do
    build_request_params("ResourcesToSkip", resources)
  end

  def transform_stack_status_filters(filters) do
    filters_strings =
      filters
        |> Enum.map(fn filter -> add_upcase(filter) end)

    build_request_params("StackStatusFilter", filters_strings)
  end

  defp add_upcase(result), do: result |> Atom.to_string |> String.upcase

  def transform_capabilities(capabilities) do
    capabilities_strings =
      capabilities
        |> Enum.map(fn capability -> add_upcase(capability) end)

    build_request_params("Capabilities", capabilities_strings)
  end

  def transform_parameters(parameters) do
    parameters
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {parameter, i} ->
      [
       build_request_param("Parameters", i, "ParameterKey", parameter[:parameter_key]),
       build_request_param("Parameters", i, "ParameterValue", parameter[:parameter_value]),
       build_request_param("Parameters", i, "UsePreviousValue", parameter[:use_previous_value])
      ]
    end)
    |> Enum.filter(fn {_key, value} -> value != nil end)
    |> Enum.into(%{})
  end

  def transform_notification_arns(notification_arns) do
    build_request_params("NotificationARN", notification_arns)
  end


  def transform_tags(tags) do
    tags
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {{key, value}, i} ->
      [
       build_request_param("Tags", i, "Key", Atom.to_string(key)),
       build_request_param("Tags", i, "Value", value)
      ]
    end)
    |> Enum.filter(fn {_key, value} -> value != nil end)
    |> Enum.into(%{})
  end

  def transform_resource_types(resource_types) do
    build_request_params("ResourceTypes", resource_types)
  end

  def transform_retain_resources(retain_resources) do
    build_request_params("RetainResources", retain_resources)
  end

  defp maybe_transform(func, value) when is_atom(func) do
    case value do
        nil -> %{}
      value -> apply(ExAws.Cloudformation, func, [value])
    end
  end
end
