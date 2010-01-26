=begin

  aop/aop-classclass.rb

  $Author: transami $
  $Date: 2003.12.14 $

  This program is free software.
  You can distribute/modify this program under
  the terms of the Ruby Distribute License.

=end

class Aspect < Module; end

class Module
  def aspect?; @__aspect__; end
  private
  alias_method :append_features_orig, :append_features
  def append_features(mod)
    base = mod.ancestors.find { |a| !a.aspect? and a.kind_of?(Class) }
    if base
      append_features_orig(base)
    else
      append_features_orig(mod)
    end
  end
  def prepend_features(mod)
    append_features_orig(mod)
  end
  def aspect(*modules)
    modules.reverse_each do |mod|
      mod.__send__(:prepend_features, self)
      #mod.__send__(:prepended, self)
    end
  end
end
