if Code.ensure_loaded(SweetXml) do
  defmodule ExAws.EC2.Parsers do
    import SweetXml

    def parse({:ok, %{body: xml}=resp}, :attach_volume, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//AttachVolumeResponse",
        request_id: request_id_xpath(),
        volume_id: ~x"./volumeId/text()"s,
        instance_id: ~x"./instanceId/text()"s,
        device: ~x"./device/text()"s,
        status: ~x"./status/text()"s,
        attach_time: ~x"./attachTime/text()"s
      )

      {:ok, Map.put(resp, :body, parsed_body)}
    end

    def parse({:ok, %{body: xml}=resp}, :detach_volume, _) do
      parsed_body = xml
      |> SweetXml.xpath(~x"//DetachVolumeResponse",
        request_id: request_id_xpath(),
        volume_id: ~x"./volumeId/text()"s,
        instance_id: ~x"./instanceId/text()"s,
        device: ~x"./device/text()"s,
        status: ~x"./status/text()"s,
        attach_time: ~x"./attachTime/text()"s
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

    # def parse({:ok, %{body: xml}=resp}, :describe_instances, _) do
    #
    # end

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
