��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2213616729696qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2212995854144qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2212995854432qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2212995852416q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2212995851072q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2212995851168q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2212995851072qX   2212995851168qX   2212995852416qX   2212995854144qX   2212995854432qX   2213616729696qe.(       ����C<��� ?���><��R��c��'�σ������|s�(&)������&?L}K�

�>�^�>y`>bV�~�O��!����>G/�����?èR��d$?���=W�=n�=��=�'\��S�=��>FRu�![�>~�	>��>F3 �����       ��H�(       ��= �@�3#?��$���D=�๼n=?�5>δ>$�;k䋾�oc�;��=oQ->�J����>��6��h�<32�z\?�F{?����>
��=�Bt>���>w�>4������,<�8T�j]�>��Ӿ�d���r��jk>�#\��٤�8bƾx�(       �-��������?t��>ͥ۽�w8?��=U�־���=��
?@�>�0U?,��><`ʿ�ȿк��� A?8-��]�>:�v=��Z��մ>ˁ���?(R�����>��
�s�ʿ)8<%����?��ؿ��l>3;�>���=�x�9����3��=�@      Cǽh�>G&�>30F>.k�=X��<r�eEֽ���𶴾
�?Oy>�4�=
��Z����-��?x��s]��"�:����м ��� >Y7=^�<��%>�i?�y=L� �c�G>$w1�҃-���V=҆l?�O�C����>a��=v}>�0�=�N>X���0O�=�e�:�1��z=���=�t@��d=�r���D�=�g���c�rAE=�j=�M�;�ס�r��=���B���¼݉�>�_<v��y��<Dhg�W1>P��=�:���e�;�	|�Ӕ���"��L�e��K�� c*��Jּ��	>PS<bŀ��h����=�H�>^z>o�=�t�>|����������'���>��3>��<��g�`�H�^�F�=��>'�G���@>�J�`����H>1Y>��˽��d=LE>[�۾�@��o����F�\E�>f�S��2U;Q>%�ؿ��A�[mQ��Խ�����"_=��׾K��K����&>-(&>�?��}�K=�f��F����s�t���g�g���4�=-2\>���??���d�>�'�<�ݽ� b�QN>�S�pmg>X���e6������]W������?�:�=��>{�=��V�s�Y>Q���n�}��/�7�(�<��E�*�v>���=���?� ?�\<}�1=-�4��r�~�>��>dW�<Ѿ�������C>_�:��R�=7�;���M��xGQ?��=Z��1L=�+1>΄�@:5:����f�=�R�C�=[QQ<���V����>vă�f���R=�V�<4B	������Y0=Å7���<X�p�u��=e��{/���2���ϼM�ٽ���=4�1���A=�K@=4��a�<�g��\�hј=`=���<����=>g�=�1��Q���s=�5�=��������<���ǫ=�)#����l�=Hh=�ߠ�dʿ
b����9��b���������= :��|#���=T���=��>�����Z���]���˾D� >w&�����Rt�=�"�p�(>:�;p��>#�ݾ �������A�����>C_����J>1�	��u����?G*.?�L	��Ϲ�u��,���	��X#��>���>Ԍ >Y*?�R�>>\�����`�о/?��>�?+�>����0پ��Žy��E�$��%0=$Z���|ڽ��(�:=C�Ҿ~��S=>>��Ҳ��i(���,�̱ÿU����<Qq��쒏��D=%����$�x�ƾgt��c;���y�?T�s�UU߿.�>RP���d}|��J���}=���=����M��N�ƾP�l�Ӑ?�����5R��I>�t��I?\�&�5x=mi"�6�v>�QX�L�J�Ց�[�%���>N��(qT���%?��W�@�(�u[��S��x$�H�@���׼��G=M�=��G�f����]�U$��L�k/$�/p�����<�0Ľ5�콽S�:�����2��>��W�?��=eZ���=lsB�3,㽆� �������M�.�c�g����'T�.���}�����=�E�mq(��(��\���M\��&>"�^=|-�T��=�����|M?��=�eP�X"�=Y�ڽ���.��0��]�?�c�.����A��þ���=�F�k����E��E�}�>�ǔ>kRO�$�����=�]�>]��G/�'�:�%����Ѿ���=�i*���⿈AԾ�I�=���=��=2&����½Ls>�N5��u�;!���cL=<��_���*=�r�ڠ���q�=i�����&����=z�_���=�d+����������=\�Ͼ^���|����1=�����-��|<F(��,���=B�뽫օ=D*S�t3۽(�軄�T��K޽0��U6�=J)�>���>��ҏF�|#�>ݍ��J�̽�ԙ=�����O�>�A?���=�h>��.���;g���w��pw�m��>�nֽ���<�3�q9l�G����@J��z��I��H���A��v�2>;�=��Ҿ���>�d�?���=$A9>׍����D?�:��j�4�R8����>?�F��\�=��?� ��-���c=y$N�mD�>��?J�=��e�����F�t�B}Q��G�{|�=4��`� =}>�>�
�a��>�~�u��>��
�H���ق>�社a�j>H�j��Y)��M �Y�N�p]�w����.�m8-��U��[>�f��7W=Q�J�_O��
D��H�����$����<z��&>O;�=��3;�Z2�Պ@=�=�섺`E���<M��z}�=�)�9I&��z����$�΋��@<>�u�=�Z���y̻�]k� F-=�=򛀿f�K����(�>;��;6I�knľ�L�������9?���=g`��^T[?� ��(R���.��}�>��?��><�ľB��۾����i ?��K��ņ��s����\<�Rp>o��=���<$C��a��>;��.��������5�?JU��;�����V�T��5T��>�����t��ӟ>�?�!�=T-�ɡ>`��>������=Av>0�����>x���Yl3���C>$-=&Yy>�ױ>4�>&D��zo�=I^п��(=W�1�K;�J��ȿ=��Y�����F�ںh%?[b�>��-�=�>��==@�P�>�C?ߣ�>�h?����c�[�!�>--?�'�@�V>Iv�)������L�$��Pq>���>��
>v��=��oL���/���-��LQ�L��7�=�̈=d��s����n��dk�_�>���ŏ�I����ξ��־��d�����8�Y�Ka��޾��#��������8�D�=�(��;
?��9=������=�Ӛ��>�����[���>Ո�;�& �7�m�0�<;2��|1���-�=Q���ΐ�=��I>L��w'���U>$?�>�_>���=�t������!�F���~��=�ӄ��о�����/={F��D�<P�9�h����?�藾��>�+?�響���Ę>V�a�)n?�O=��2�9m�>l<�}A�At�s�x����{��>#�p��Խ���`!>��_���;0'>
�(����N�@�9x�&oJ�qF>6?�>�c	?9�����ϛ�g�f�aOP�?�
�lG�>R�KM �q6��s�>�������J�Чؿ�;m�&t�>g�Ƚn�?�5o_�:������?;�߾�8���ﶼk���%?c'ڽ#Q�>�ս1������Fb���J	>@�Ѿ'?d�M�)���\�?��>�B�Pؾ)�K��h4�6�>ʗ��-?�Z�|r+��p?	C
�4(`��Q�>��?�b?m��<c��E��"�>e��> ��>����Z��[>:������=�+��	ͽ�d��f����m�����~����ؾ�	y�C��>�I,>�>�M���2R@X.H>S�}��_A��SU��1��<�+�>����"��֟>�0�@���羝%¾q��=I���)�����q=Ǧ��ߓZ����5v�<�ɾ�Xｌ��<����D���2޾�ǹ����=?���H�?c]�P��=x�K�c��/���t��r)L>�K>}���_?��]��b����+���k�H7Ž$ԑ=�$�_�U��;Ľ�ݐ�f��=]<e�	*��A���۽d_�=vֽ��=��
���"0���=u�� I~<��@�CEýZ柽�����M�ɩ�=? ���n�<�<�={�@��}�=�E9��A�;�Ժ��� ��W�<��-=����8�^h�>|Yp?v횾�T����>�����{��>� ��=9p.?��>�	���#���p!<�>�����-\���q���"��=E��>���by�=����j,?ygC��g����OPƾ̓�>�mS�Z������wV����ܡ�����
��`�������o�>E���[{����=dP�lw��X;�z�sd�>v�p��i�2�U<7G�L��6,���VZ�	@��0齯���'ʓ��p�jE�����D�k䰾
u���ث�*�!�S+��H^� �-�[
4��%���>OV�k��~ �q���0���FF�C�;�+���'ڽ v>1o�?�I�����-�R>r�J�D�S����<�T&>�ۤ�D������ONk>IK�=:���>6��RM5����=s͘�(B9=�uJ�ܫ��� ?��:�d\;>�Ӿ[�ܿ��?ţ�?JX�36��3��3�>tm������dнY��������C`���E���=����njv<��MD=>�w=I�<z����UP=�+�=���o�߽C�4=}f��[��Pg�Z=w^�=�B<B�=�V��X���Q�O3�����;������漨ǵ�H��MQ�ff-������T�<��꽞�>�8<�ȼ��z�{�(�R���W�=ǫ�=�=�%X�N��o7��oٽς����=�E���󽬥�=�p	���3�����?���>I�����*�\�F���-���/����8�ϼK�C��&r=Eb���<����y��=���sN=��>�ߑ�DFc�u���>C��<Y����;�PC=��>�T>Br��m��K.>uT>��=Tf�>��j>���k]�=��)����gxR�j���L��8>��?�t��dz�������p轮�">L&J>4 E>h#�>QcD?E-�=q�����<���=���=H�=������t�������;���[���<R��YT��t�>�
J<�ὲ�=�'��⤽J��T�T���E�����%��{�v$��=5Ve>`�Y�S=C2�򲞽3��#qw��AY�����[iའB��5c�=AH9��������a����^������w"?�j＾ ���[�����Ӣ������q!�թI<���P��;$u?��;�$�^Q�(0��ͫ> 3����F����5q۾2J��9x��r����2�>R:��3U�a�;=�����Z=?�&Ὄ� �_$��F=bV��-f�a]�=������^S��Yͽ,�M=�H�	�=�T�J�lcM����h*5=kq3���ɽ¼>��F�G>Yo�=���c@;�ۉ���7 ��=0��8V��5T=o�^)o���ýC�y�P�=%Wg<��ҽ2�8�=����޼��A?,��� �⾗����\��ޙ��g`Z���=~���������#��0�>��>�h=&Q>0H�='.�>��7>|ۏ>:��=��x��*޾+��p�5>�]���G�>���=�q��.�>�n��'>�G\�<@�:>>�ɤ=ݤ�>��?q��>�/��R�=�u�>p�>�ܽ}W�>� 0>u->H�����>�X�>�d?T���7!��\x=��(��2C>���"�ȼ�a�=Q럿!���������0��x��S~4>~�>�00����?cQ�����e��H�"�+���R�x>�����+���Q>����x�ρ\������?��]��#I?ޤ�>"�*����]'t����>�qA?EŶ>��">�J������p�o�h>�g񽞣'�#�I=���4>Fj��ϖ�>��[�3W�>�b��2�Ѿ�)нi��˭n>�O���cD�U�&,�����,D� ����w��=�)�ѧ>��z����=����1�&�=g݌���&������F�Z�]��eg�2k��tM	�VKA=��N�=ew�;�/��h�������cP>� Ѿ��p�~!ܽ�i�����;Z='��<����:�n��y8��̈́��(�>h^K�̷�#�,>SBt��s�=!����>�r��wk��ҁ>��,?���GjD=A!�>�Wr;� W>p1(����go�>�*��j¾ǪԾ��p>�[���?`�w% > �G�� �>�?M<��?���hg|=�]ut��]	>�`(<�C��-WN>�s��>,,�=�H>Ϝ�	��wK��sr]�����g>�������	��+/�<��ǽ|�K�+��3�=RN�<�ׇ���ͽ��^=�jٽԜ{�'�=���ɼ�;�= a�>aG<�2+��EȾкx����<��9������=?�Ľ�I&�0%?���W��/<Eǌ������=Oh=�v�����v��!]�>���=oEx��Ր�ٛ��U�;\s���y�>�f�=�[��$̾�����S��5��|����PǾ��!8>�9-�v���������<���=�{���O��s���T��L�a�m�����������J�����rD�rt2�(       �P?gξ�!L��&:X>�#��L=���<�����J�>M]վghJ�?B>�S�u��C?N��>��>?�x������/>�
>���(#��w<<�O���UF>I8>���mF���V3�D�I��n�7?DO�>��K�"�<G?���G����"��