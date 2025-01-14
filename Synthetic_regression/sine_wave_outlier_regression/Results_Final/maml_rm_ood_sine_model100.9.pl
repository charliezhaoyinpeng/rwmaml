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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2128939432656qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2128939435728qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2128939431312qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2128939431504q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2128939435824q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2128939431600q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2128939431312qX   2128939431504qX   2128939431600qX   2128939432656qX   2128939435728qX   2128939435824qe.@       ~�Ͻz(H>*fV<�E��������=��@=K+N����=��8�g��ױ=9�k=��0��c�=	�~����<I&0���i;���������!>��
=hZ�=�|ڼ�+��[?���B��&
<���s�����ǩ��^��r���7������==P�#4�>V�V��s�>�u��jR>�5Z=����w>�V�<���/k�>�m>`"��Y�(>5�e=u�R���ɽ���>zj0>:{�����=���>�eh��P�>ᗋ>��>6�f>�<��Ŋ����> �ֽ�:?�3N<^�6:��%>5��;^��K�(=�}=6#�=�O(�O���Q�����j�=�� =gQ���j{��>�=�Ł�J/�>�#罺�׾�r>Li�� ������g�=]v�>��վ Q'�m��?�<;����&@�V��<� ѼB:�>�ʠ� ��=���������{8�f�)>	�j>:�t���?���v����e���"����`�8����=##佐~j�]��X�<@�r;��x=[��.�=��>n1����Ƽר��3ؽ˴�\���X�=��=@&=`	^=����*'�=PϼnV�=3'��`B���f�=�����Ͻj��pѼ1���q>QK=��ǽॳ=Y&���S���z��:ӽ��Z�/<e�������<l�;�K¼�a�=-l��(�Y�H�G>{�ͽ|�0����<����P���ƽˬ��c9��e0�I�W���=��t��RŽ��9��<���q�2O���=�D�y�n��r�$P��-���\�M�Խ�=�C��]���=̢����<��;���=���E�Ͻ`Q �d����	@���o�bDX>
^t�8�D�5��>2�?����u�j%D��?��B�hy�<C�ڽt���z2��V>��=�C�>?���Y�.?�>�i ���cH��J�2>�ou��n>x~
=^?�{�?��<�H�=��t=���7�>���>!�>j���td���>�-?˖��#S>�r�>�~�=�}�=�R@�U^�>������S��>>�1��O>�;�=�/ >�=�<oX������Fʾ�˯>��ȾQQ���q��4!�>t.����>$c~� ��y�}���I?+n.<�u�?L<�t½�6�>�ui=&��<o�����:>� >E<�>�7>	B���<˜�=�^=��v>�����6����>��#�o=k2V�P��=n?T>���>ʈ=`��=�da���\��m7��zֿ��н����H� ����;0!������\*H>�2��?�ƽ��c<\��=�/�=LP9��Z��I�Y��*>];a�,�!h�=�z���ǽEa��Q8���3<K`�T��<�H��)h���`�4�ּ>�ܽ��H�5�^>�c���I>p}>�~R?�K�>�k��_���H����W��]�9�=	�=�J����=��H�0����:�AU��38����U-��y7�<������<'�1�"�%=aU��V�ڽ4u���8=�4=�>H�D	q��򽷤}�Cx�=�_4�{�u�h޿�'�<m9�=�!=Ф�=�=�2	 �A@�����Ͻ'v= S��|�>�2�=w��G��gl�Psx�S�����_�\
�=� �i�����>�n��G�F�x��<�3�� .�������L|=�|侫T��.��=R꽍(�NB�=N3�<����?n������y�����4�پ�Gl��p{=�A%�����毽���=M�)�(%�����N�����牽����8?U�- ���$L�X=c=�I�=���R����J=��<n��=|����r=���=O\T��ڿ=!��/U�=�x/�Û������k@��i�=/[D�*��T=F�i���Ｔ'�-�)�F��=�M�fb�� >3Ȓ���>p�1<� >��f�c�?cJ~��S����=��Ժ������<�q=��>�}>��:��i׺1٧>�}$�lώӅ���>2ޖ���=v������D+=��<�����]� N�;�Ĺ�WbK�痝>�!�=�{�>Dj�>PR
��Yi��@~�!aپ7���>f٩��l0�^��?:���܎ƾ;y&>�4��Tٮ>�{g>
,�>�m�ȯ���	�>�K�>Bj���Q��B+=>�ȫ���>�]���~�9�	E��/2e>htv�_��=�5j<�r5<e�3=6$��@C��|�!�Q�:>���J���=���>�>}��DI>?�6���Z����=
��?�
p>Y���H�=�["�k?�/���T������	6r�������XN�����M����ξ>�j=8��IC���׫;��ٽD��;>W]>|C�>"	�%^�>A�2?Č����=Q=K?����"|�]s]���S����o�=�~�� t������>������<�N=��οC[��k;>R��=�#��iD>�맽��]诼��4=��+<�=&࠽��ʽ�b�y?Wz%����>��=��>˱o>�I���Ï���i9���?)��>��>
r?�G5>�.�=�7O>��m��|ؽ!Y�<���=,#��˺�er�ذ=ul�;]�>!��<^�ȼ�F=c1F=�j���\d<�Pǽ���z���X�;��=��ּ�c�=V"��@�@|׽_�=ͳ:�D-�=�$ѽ\	���Jݽi�����Z�=��L�Z7<k��=[�޽� ��b��ؗT=`$E=�A����$=H�����>c4��(C=��>B)�=Z5�=p�I<(�=v�̵"�Os�@�C�v?�=�\�� @�7HK:==D�X43����-��8Yݽ���\/=��>�;�+6���D��Y�=h�O=\����ʽ(���$�(MW�&��c���b�F�ÿFї���п6�ɼ��:���݊+��ϙ��G������>k��ݘ���a��͚�֣@���">K��K\*������%���?�ݿ������� ~5�'�t�p�>�%o���*������}Pn�./_?���?���/�
?�X���{� bq=S���� �����4�A���#�>D�<�ʝ��蠽��by�810���>6��=�J`�]��h* �_��Y�͢½"�ӽ�ٻ����>�vV=��P�N�
��9;�S���C����=�ϾB�<�� ?�,>�T�>�+�>ƿ��=ؽ�N5�=f�ٽ�>ž�B>�=w^�&>��𾢽����~,�C�z�}���hɽ�����b/[���F�	缾R�Z�8`�����]���i�4�y��"��u�c�q�����K,B��/����{=)�����D�$J���-�_ϕ�q��=yϽw��e墾ܸ���[;o"��xüқ��7����:��`Z=� >%C����׼�.�'�Q���=���<d�O<,�h�x�4��̽�DO����=�P�=�>��?�5����p��'f�����d�c�ȼ�iq����R�M����vƽ�=ڽ����M_��2{j;��H���?=�=t ���{=�"	��-�����%ɽ&#R��Q�=�`D<�F�Π�=�z��,�2�(����E�����Qw���'=��꽭�(�f׾=�k=Qn{��V�<��(����=����`�ܽ �`�Q�=�߽��a��s���n�����*{6�A��=�-.<���I~���T�=����}��+�H�E=���CŽò���{!>������h1E�v��4fs=����i���[н9���<�'���i�����l]=�VܽB*�=����.Wʺr��=K1#��������'�p>�2�?&>'��>bq>y���0!�������=>[�=.a@�?�?��g�l���"`�=L*���g?q�?�!r>o����A�����=&P?Vβ��h�=XjJ= �>v�@T��nƂ�=���-/�=�|<*]�������罃��n�>�1?�۾�#�s6��Ĭ}���P�~�7�B�">Eh>�4>�������t�<<�V=��E=�;���6��\>�����<=sI���=�X>��<=�f����'�H�U��==\�<�����GT]��/�5M�<d����l�;H$�7肽g���ؽ`h���D����=�����˽�>.��N���ʳ���%<cs#���a=�D�Ob���D =��׽�����=�zm�=����Lu��a�=x;���=�2
=]���j-�v�D<�}�=�ݬ�t|%��$�=���s��<��ܼr�=.��=�u��M?o�a�ڼz3�:��Ѽ��K��g弊���̹��RV���/��r�=\[i������`��ԓ ���Z>�s��V�<�j�=���>^���
�0�18�>�#M�F}�_�3���>�.>��z>4;z�#���
����?r� ��z;��<o�ې�| �=�ǭ>>��=����6Mi��.�uC>��>��=�_Z>�.�<�!t>7��<�=� v�se���	��n�uƽIc"<`q�6���� ����"� '����%�a���&�!0�#ͫ�Dz�\X��N��'�p�$0�a��?�P��5�$_`�H�-������>i,=�\�9c��.���qG��X?oG�?��K��=>00Ǿ5,ƾ+�	��L��纽��=v��ƅE=��1������up�{?P<ˣ|��W3���==*K˼���<{	�'l5���Խ����q�=Ĺ����=+�I����)1�=O6=~bŽ;p}���c��>��2�>�G=�븽P�.>�ܖ�0ǾZ�h=뗬�}����:� �c<�
�=�$>�!�����=�r���c���_�<5�)� �h=�>��<
Ɇ����:R��K�;�� ��=�`=�_=x�=%��=lȼ��=����Q���`��=#&��߹׽p�/������
�F�l=�T�U�>�=Mʽ=rz�<���w枼��S����?>v��Ef���*z=��>���>S��/�>����`�<V}���g��d�>����\��:��>&h����=������^�n�"?�o����������[�P�^��j-���>�q>��b?���>L�� F�G�*�� оqm��g�<�����ϾV�q>�L�ko��@�=��=e�<���>`Ҧ>E)�!N����>���>�Z彉�g=���>Sl�Z�=����l�B�m��?S*?��f>��x�����(���_k>��ͽ5�W��˽@�>��ȿ�(>��F>&�m>#N�>OZѽl"�=P�?�O½�����D��%`��P+��1��<2=7�_�ϸ�=xL�k�ݾ�~J�Rq۽��񾉭���h���=ѭ��7'�U������/пr�M��SE�C����=&'�q��=�qq�����o�׾6�>ޣ�?P�K>#>$a�=C,��һƾ}1�9->3�	�\��9��>�L�E8�=dP��C��=y�7>�-=*��Ƚ�-3>���;�CC�.�>l�D=�6��=3S/��+�>�D|=�b���k><�A=XS>����<E
��a�.��O%����=A�e>c[�=��&?�>D>�]��M��|����!��l���n>�C�<l)!��>?+#�>f#0��R���?pͽ/P��;�>�i���g ����ᇹ�����;�N�a^>�g���~����>��>otP��>�&J>�ϕ>���==�C�m��>,?K�?�n&�>�N���>x^�r���� �B1�cl�>+���:Ct���������b>GGȽ��v�� �<A��F��=v�{�����0� =�� �<�� �ݫY����=$��.+�=�^ ���P=|�=G� =h����༼�?=�;ӽ��1�r��;���������H�3�N��2=��jkU���=�#�s�=�8����5���潇"Ƚ1���p��)%]�e� ����� wн`�=<& �� >�Һ�=�i�"3��>����2�f�=pE̽�eн3^��c���d���9��6v��o2=Lr,�[�������<w�<��h=��=���G|����½3��*�q�=r6��[�?{�de��=�|
�]?Q@�>}Ɵ>����f��6��<���>�ֻ�?j��XQ>j�R>�n>�0w�S��W�ڽ�����<�>p��<��=�"H���>�u=���>����r��J�"���x�ȿ�����M~>�4ҽB��<�1/����<x�D>�%`?F=	?��\��y!>;�[=T�ؾ�@�;��=1�S��0>>p�`��H�0�^=��Ƚb3X	?��3�0���I�>�� ��>w�O�?'��>�2?���>��-���͇��*M�>�l�>�I�=�<k�/C�|ZI����#b�>�O�>(       ����~�a�N�H���^��iP���{���@�>dm�Ͽ���=�mL�%��1�Z�wiP?ND�>�/<pC׼��>Í>��ѽ�W����=��*?\4�=��=�Y��F�T�?A���K������vY=/�?�t������E�:��Y<��z�u"�=       B��(       ����nֽ��4>�@8�Gq��d�]�Wa�=��g6��5��׾)�?Mt�#S�8:?0�7�K<� �u�������<?h�&�?��.�l����jӽ������f��qʾ�ׅ��&�-?*�t>�i�;A�C?9i>"�;4��Т���Ѿ��(?(       X� �{bR>�>{=z����[n���Ij?k�˿��=�~Ϳ����>�)��\����ݿZK��%f��\�>�
���ǿ*��[p>��>o�ݿ>g�<��7�	߻(͸��K�>�?V#�<{���>P��
��>Mh7?c���8�=\�
�0/˾(       Ӫ1;��?�4��>��P<[~�=��?:��>L�\>fǥ==�&=�eJ�0�*?�>C�C��I����=����mo�?L�f�S�>1&�����<1L;c7��$���V=�4$��z�?�@�=��>o�>�"��b¾��f>��e?și�n���ڛ>���>