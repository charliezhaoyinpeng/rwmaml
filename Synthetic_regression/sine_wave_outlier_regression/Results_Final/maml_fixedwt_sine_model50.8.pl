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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   1552333389536qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1552333387808qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1552333390400qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1552333386656q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1552333391840q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1552333389056q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1552333386656qX   1552333387808qX   1552333389056qX   1552333389536qX   1552333390400qX   1552333391840qe.(       �R�P�+>�R�=��??[^*����>f���&n�>vE�����>�h~>��Q�Y�=_Gｷ�GF��tоzPJ<\7\�j�ףu>���+�D>��1�Q>j'��_�>�N����=�a���1B���=��0<ɰ���m>n�ʾ��1�7>1��8>�XD�(       ��=�*?�=�EͿT󌾆f��7�� �(?67�;!_��-�?J���c���E�^�b��=�����>ф�C�ο����������?�C�L�
?ES��������>[k(?�>�<>�C�oΈ�����.�!��`?~G����?�L%?�e�=n��       � a�(        �>{C��?%�$�)��>
>f�?E��~W=8eP�1ά� �^�>�_��3U>��美�Waƾ/�J�b)��\B?>?�"�>���7ľPI���½��^�>���|>�e:�mF��Ҿ��>�S��ʖ��#7�n�>ŴM=+b?@      �\���&/>�5�<X���z����<����AO�^˥��=��<>�R�c�J�1�¼�bX�o�ν3���9ڼ�Gj��������m�U�Р�<@Xu<A�����Xd=H�����G蒾oK`����ݵ򽆌뽬4l=��=�̀�.f?������<��>��?e�ѽ�(�N۳>�7�= 25�x���7w>�0_�Ҍ�?t�0��<X�Dg>�&�>y�����\���$�A�Rʾj!������'ҽp�ξ.��қ<���>������3� `>��Z����=���o���4?7����⋾@H?x�����>�Z�f�Q�=	
�=��P���=�,��~���� =�+��_�N��6�Z^�:�պ� �=�K�;A�n= M��l�=0�1����=������`�\��uK��4f�k�d�&�T=7hF��[���޽�-�L��eK=r�ͽb
8�UE�#�d[.=0����k��8���7���X���1>4B��u����m��	�=H>�����d�A���߉>�=��H>�� ?��'=���=�IC��	��4�����"�	�i�����x>�R������]F>��!>69v>h�X>1~>9D<�?��
���=?�j?~�>;4)�8=���@��Ȏ�8o>il����=�揿���?��=P�Z=a#����;MMy�J�������=,�s>��=�Q�>�>n��dx����ؼ�]�3=�>��1�[���1R= m�=+�>/�$�~u�= 䭾S��=�؁��m?�C��ƈ���T�߽l>����c�-��5����K���c��ً?�漳
Ža'�*� �݁߾�N	�'Uh<%5N�pe?��Jqv�Z�J��������>�j��z�=#f��?��@�\�)�ս��{��`R<�Ҽ�U �8�=��ÿ�SK��=>D�H?ҞR>|+��ż��m=�.�my=�4�����<T�=���s����I	��]��QT�:0�ˌ�<�켽�����J?������;s=4�?�B#>�+�3��=�&����9�nu̽G��=���=]񆼕%��E=š.=�'�=�鼽K���]�c�=-ީ<C`<H�῕<K�G%>��%�ӻC�S�>s�3=��]�&���Ͼ!�C��.���"���:�;�l�������j+?@מ�qǾr1=o���_�=����Ⱦ�Z������0�+>�����ǿ�����=:�,���۾M��?�G2=WO>I��>Au��b�Z�	լ��{T����[*��Ti�`��;�.6>��q?�5��	Ȓ��Oi�����'�>%�=���������`�?=F��#8��(��_[<�5�>Oo�'O�>ɉ���������>l��4I��5���7���6�����O��F�?YO��J�>����mlV=�R=��n�����=��S��+��� ���W��9�?���=>�������m��6e��Ђ"=e��һ��W�0?�~�^�Ȝ�<F�:V��˟}�š?�Fb��������>���}+���8�)�=�����h���s{�j��=u��=�����K>h�Խ� �#NK?�H=����"־��<��P>�he���x<%R?��	�^�8�����&����c;���^Ž3��]�+�1=iw=�7���9>p���H��3c�>�9+>N �0��~G)����=tT�"`��v�U�{���N�(�3wȿ&��w�׽
��<梾4�]ӕ�����p� ���ʽ��张�3�4��/ؾ����<q�򩾊�a�W9����2Ͼ^Ծ�/��d3=���=���+��>���,[9���̾���*����Y|��ɾD���38������j?�MĽ�K����=H�=��T�;��=�(�d�e=���k<��G=���*ޓ����8;���6B�g�<��=�������ٌ���ٽnc�=���y���v�� �{�;�I�Y��= ��;z������k)������ �Tq��������ֽ��{<��ko������[Ľ,�,���Ż�0[=R�=�꽨���� >Q�)�v蠽g�.=Sw�Z1�u��<�"��_V=������=d�=���P
�<_�m��A��E���ٽ���=�	���[����Y�ӽ�=�7�0�r=Ͱ�,�轰��=Fb�<�*�)��U�=I��=��I��%\�박�.aʽ!���3:�>�=�ۄ>Z�?Z���UA���<I�;k8�|�E=򡾑�z�\o
��̾���t�z�^����>d�{>T3N=�X��j 1�X�F��佺�ܾ��<�Ո��J�ܾ�!.�w��=9!��Ҁ��0�>�/ھ��">#��>\>
薾۵��Ƚ8Og��=C����3�Z��<�P�F��ᘽ� >��<P+��e��}���0]���<2�o��L<��1����=*�&��½3�U��{����MA.>`�=����=��!>Bc����=��վR3��\$>8�>eؽ������>$���rr+�%>�<�6�|3�<��/=�9k�zb��ь5>���>Ƶ*<�Q>A�W?�4���*<�<�>�)>��> �H�R��=�o�L��Ώ�~�^>���>y�<J����>�z_�vw!>�6@Ӻ�>*5��Ͻ�y���=��P�{���j�K<PR�6Ⱥ=�Ć=��?=�x�����^�=t	>���=�̜=*��N8�h&��$�=J���b��x������3��ɟ"����i�XYV����kV<�T՞=/3��v���uɼ����Ac=w��� K�����=�!߼7�=@��=�
��
�>�쀽e�?�{��qF�DǷ��:��������>߿3?�����b�&�>��&�7�>^��+�t>e�-?{�>o@��!w������S=8��>tԪ=*��Y�>wz&��43??�����>f�Q�mT>_��5~�̹-�`�ܾ3~=c���-?�0ý�g���\�41=�����I?C��3=���?B�7�f7����Ӿ��-�/|2��H������}	ɿ�k��ɼ��WԾ�-[�}�>�c��j�V�>4s==�&�B��YP���ɰ�p���eX��G���
��a2>=KW���(��X��U[���f}����1e���wF����=�|��Z5�?<0l>�1Ҿ���0����ǿ�ʷ�^>z�[��'W?VE�w�����ʾŒ*�Vj��ԓ-�<����7����|��S��#���;ג>��8e'�&�j�h	�Q"A�_���he\?��>���>���X��<<Ƚ��=*ɽ�彀�h=z&����!�V�=u$���Fu�m���K��Γٽ#�����콀,a�4cN=��ɽ�y�8�a=C岽$#1=�wG��F= !麺�J��3���y�=�@�=�.�<A
>e�>?�L��=�>�4��M�<�k�08o<��F�2�>��k��/��[���<p�=�k�>��E���GHw>
�׾���?-�<�LR��M��׽�"�<�(<�:)+��Lm���/�d�U=t1y�]t��4҂�>�>��.>`��<뢊��;��
�J=��)���=qm"��)M=��>u �=�ƿ3K<n�����=��9	t�P��<�ţ���=�ľ��<,�����=&?��d��=S޾��=p����:���9,�Fw�/g���Ž/����mC�<��7=��{;���<|�d��E�rP¼;3/;�$-�Xc[��fP=�`5>)�(����t9��N��,s�>;��P�A�.V'��0�=�$����?�����_��!8>�'n�����j��,�Nѓ��೼Kk�<����P�x(��,hs��Z�莛>Z�6��ī�Ҽ&�е��<����>w�F�:�o�"�	�T��i�L�߯�v?"�{�H�=�<�~�N>�6>��Uݖ�bW>t�x�"o?&���뮛����n{>V-���>�>)^��=)��옽����໾���>�?
�=�M�?bϾ�eھ �_>�F��]���:�=�����!�oW��F�a>��=�\̾0���#$?�d���@ ?�����!?eT���8����=lJt=Fo���?��.> 'l�9��>�pY�4��Z3U�����165�鴱��,K�@g;�����\=�󌿛��:G�i>|�����X���=ڀ����¿>w>LⲾe�z��k��%�>L���J
��{=�]�� �>@9潰�g�{{�{˸<��J=�z���=@��<!�g=[�>PC[���9�K��@�<�y��͇���)=��=Ϻ����P�̲Y�n ��6�������m=�""���=�Ǣ��魼��ϽX�gq��t1�p��<L�����ZRK�,���{�O=���]-���=	�s��vA�<��`<
=T5�y�k�8�=&ɒ��[�y�������D	Y��j�hQW�N�2�_�T�$��;��/��P��b׉���Ͻm�ν��u=\ի��T��(R����x��\�<�녾��%;�˶���Ya���!�9!=�@>Ď���Nq=�7���
Z�C��*f��C\>V9���f}�i�k�S*����U�2Gb�?�by��ƚ��ȑ�=�0�u����f9<��ܻ۞y���<C�������ǽ3߼��z٦������mr�P���`S�������a���F<��=��<^=����o �	
��pҾm����D>�� �o>c�����=�K�~m9��6��>W�����<N�0�n��?�̾C���^�����>��?²*=7�=�S���=���8q�;�s���(�N�C�ۗ�zľ\����I��ϛ?` ��|ʿ�<�>�"��yC�>Hɴ>���>��"�qq���>����a+�;�Ǿ�>�<ޅK��|?�cl�~Ę��Q��j�s>��'��Ň�T��ڵ���Ű��B�8���V�>�_���>>��ڽ}�
>?�����N�>��p=ה�bQ���>s�࿷�۾���9��=%�L=N����S�=���=+�v�2��
�
�<:��1�q3]�筻��#���u�k牾�d1��4��$�W���x�cI��1���b���a����=C��5#>}�ڽ}^��.邾�����0�Q���m������to��S�����%`�EEƽO�6Nҽ�=-t�Yf�=棒���ս��u!>bQ]<ON�?��$<0��e�����]0>��b���i�D� ���5!�qW���S��1�>﫫���3;���5􇽀}5=Kf�-�]�GP=��<��t��=���t��P��l9���>�O����;Ƚ>���i4?���G����O�=�A�=iɽ�i�5cݾW� ��%\?��S���A
>D�Ծ؄�=�Ͼ�q�w2���6��̎�>c��=�6>:8�>�k���l��C>c�>=�=�^��-þ���-��>>��=#E�=Ѧ���� ��Zv�Gs�=�>9z�?)�2�i�+>o����f�w�˾���=��!�B?1[Ծ���;b�������-I^�{跾1�r��x���<:9cɽ�u
>�i�?�����ʾ���>�����3���c>�0������*�����.�+����Au?��>)�v>E�ҿ��A?�<�<�g{�j�3�`�?=Նѽ6N?ep`��[�ي�>�{�"���ܽ��{��8L���ؾ%̾N芿|���6�ʛ��k����>n�M�0AȾ��>��=�&�>�h��Ŀ�z�<Va���8Ծ���(�=J�>�,�����~	���[��ž��4�)�;�������82�?��潗��=�S�w��>#�Y������񰾊P��3�>��K�6���9�jᪿ�6z��O���A>�t���ɾc���F��=h���x���z��?J�I]~�:����:�$�T��?�Cp=��>��6��ѿAE��d5>���ү�0�T��K��/���t���l�$�$�e�J�$������yU��S/����)?:}����BG��O\��~�m��KA��GB�n7e��ӧ�Ky���W=�+W��������(��7S��Mj�W�1?��o�p��>d�J?�Ot>��g=?��ܖ�;��= 	X�XsӼ�� �ռJ����>�{�9\[����Խb(_��T(�7+a��LT���n=�r����>��K=����Em
����<oj��ƽ=Di�=�p�>;�=�w��0�<��4=Ǖ=���=�$�=[V
��'�=�-��3�M�\s�h�`�(       �=�N��(��G�e� �'��о��= �t���>@�Ծ#���p}�<E��<����T{��{=;���I=����c�?��?B�?��T�$#,���0?#	?'q�>	?I>�Tg>�.1����>1)?+�>2�~��%�XT�>��K?W�E?ۦ��m��<