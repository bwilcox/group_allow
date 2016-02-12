Puppet::Type.newtype(:group_allow) do
  @doc =  "Allow user accounts login access based on group membership."

  ensurable

  newparam(:name) do
    desc "The unique group name."
    isnamevar
  end

end
