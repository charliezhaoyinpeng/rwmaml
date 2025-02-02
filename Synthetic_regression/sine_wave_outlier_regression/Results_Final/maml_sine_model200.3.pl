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
qBX   2327161785904qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327161788304qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327161788400qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327161785808q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327161786864q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327161786192q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327161785808qX   2327161785904qX   2327161786192qX   2327161786864qX   2327161788304qX   2327161788400qe.(       ����nԽ�>��N=�ֽC,m?�.��%@�?�)��X?h2�?��U��Q��>Yɪ�Ŏܽ�^ֽ��c�P�?�6ڽ�8O>�E��Z���5��<W=���U�>�������76�1���E?�����E���Q�T�>�&==�?��9?U1�>(       ��0���C<"ر:j�=��Y�4~=�f��ޯ<�&n?��	?�{���r >3��@<=����>�Sj?����?�+�K�1�W�D;1g^=�}�>|v澷d��(
<:�a=�`�����-�<��	>z�|��=N5?��>R*�<�X�>9�<D��;�Q>       '���(       ����G�ن��[�Y>�T�=tv쿆f���rw�a�?Ȣf�� �?.Y?��>2*��a?n��>��'<�H=�0���=�/)�	���	潈E˽��>˼N� Շ?�cP?ƺ�>Pi��J��~��麽�>�s�>��r���� �<j�?�,?(       ��>��ݽ��>[�>�
���=޼�>��i>�9���C�zk��a+�=���<�
�T�_��0R>I\h�u8���鼿��F�J ܼ��%=M�𻚉���V�@�t��y�>։@>"�&��z�=c�]=��񽖀> ��CKο�2<�����= ��m7�>@      �� �U<>t}�����X?"�C������=�j�<� >�V�2��	?���;hJ���P�=~v+�y#?^?xa�>^���Xz�R/��'>���$�)=/��>)��;o����ǿ!Ǟ>�����h�<���;�k?�����kq�JF��@{y?�yN����<UEd��OQ=��޽B>�����P��J=?#�=J޽D�!�[���c&=o�����<i!l=w �e��Q=��{=Eƕ�=43�)���=���缥Q�Q��B�<'5<�49��u%<6�=�}�M�ܽ�W(��g<��M�=�7H=7�Ƚ�����>�9�%O� ��:����`ۿ\�2?�I���>��J�ž��=	�"��ȼ�nA�a<��X0� Y;��<<]j����9��\t��\J<:X �n���^'>���>�8������>'�����ۥ}��I<��?������������?>�M>NV���I�U�����w�>_��F�ۿv�=�p��~?>>�E?�̑H=�����>�P�>�vo�~� ��fh��<m�� <C� >iJ)���4= K �u1�>�5�=�@T�m��>�,�>��=�j$���;Tv�=���>�{�=^.�>s�>�-l�������!�7n�=���=Ϗ#�s;���9�<A�t����Y~Ǽ|p;�	����'���=�jX�c�=i�>�H�����Ѕ:���c<.ZL�/�=��\� ����/�s,�i�=l鹽gk��m�=�|��䖃=P�$<�g�Z��ƽ�J���/���6�#�1�u�?|��>���B�u�~i����?H���3�h������a������㾐��V��z�(0���,�5j���Ͽv���"(�ʒ�=�(ݽ�N?\@>�<s����:��OT�g�M��C�ƽ29>�Im'�A{��Z�̾�-��P���M?�;Ҿk*��4�>����>KJ��H�@�!��ɫ=��y?�R�L����}=�)�����"?��h�!�J��Yi?2Y�Wl����.�]oM��v=@�<>����̽<k>>��>�p����>��c��l�S��>U��?�d*��B?L#>gs(?]籿m�ӿ@	?h'>ͮ >��54��W�>,�
�u���E��3I��3
���=��=wE�Fq� �ܼ4��=���=�/��پm2���m��<�=�E�=���>���p� ��P�f�r?����|�<���o���hֿ�Wڽ�9��M�οh��>|�0?�,��H1�kN�=ZFk��K�Ͻ�������|)>�Y=(e{?Q([��q��`(]=�V��+K�h���J�������'�� �>u�¼f�">?þ�c��J��=�����֙��rn����� ���n{�}T�����J����?��\>O�r?PU>��z>�G)�ֱ�?@<?�P��]L�c���پ�&�T�)�C�����"L���=l���@��ô��#Y�����l�.���1{t�qȡ�	>��x�>!�ƽ����#��\��<��*?�P���t��ŉ���ؾ�=�D#|��vL�Z u>�m?l���R�S+������>s���^?���@��h#?��wI�>]���2���ZP�>����w&ɿ]��xD��JS��8�Ѿ����,<�M����<t���/��D.�?Ƚ���I�> ��Ir�_,?�Wj����>�	���b�>[���i�7��?�KT��N?�'>g��-4�vI>��!���ᾘ�o>t��T� �x��>G�0�s�����>7�>>��>���;��>�޿���>����,���Dj|>/J�>(�5��0ľB�V>�>m>o�=hѐ�H�f?�K�e�����x�a�?[�D�k>��E��0ᾓ��=U$�>�E�I��Rb/�H��<
�ܽKQ�=��=�a��=V?��>�M��*���ڽ�Y��c4=��>�]�>�u����S���=�9d�ȇ>*#j����>4��=%�}<��3>V�?���<&wi?�jC>U�Ͼ.�=b�>�Fy��}�>Ja�>�ק�b!�O�������
=��ҧ�>�M�ˑ��8�ѽ��8=jw�=L̽�п�a�ZC�=*`�X��~�7��t��=^Z)��P�=T�@?�`+?k��#$>�n�>�����z�D�O��彾0�C>�C\;�u���[�Ev����E��N
>�5??Å?n��>����2����Dy>���>A�q��灾�p�?dZ=�u����ƾ�v�? ���n��>��>kb/�%��Z�>��>��i=�K�<��?�5A��U,>�%>��>q�>����C?�A?��A?�
�==JB�k�>l���%=ȁ5>�e��́���i����>�j������U�=�|���� ?Ҵ�>H`�����ylg�QC�>�lC�;�F�(xʾ�A���T�-��=���=��G�V�Ž�e6?̃>�\����>K�|�Iq<9]�>7K�=�t&��g?����6�>���>�?�=�f<�T/�����=hQR�q����D�=����e=�m���	��:ܶ�<���=��"=JC�=|��t��=�C
�����V�нD�>����3��*��m}���=��=�i�jl<y�����J���̠=J��=���\3�=`�0���/=`4-���<���=�~ǽkE>h�=��>
=���A=��o���/�YT�/7��F�L��]�=63i���'^���ڼuz������Bv�Гp�OD��+4׼^K�=�hp��")��
�d�F=m����$��;J;�렻s|W�����H��FN;�ܯ���_���ý��ǩ>e�����?�`[?�X	>�}�7_�=G����'��.K?+�?k3ʾ�Gս�X?rZ��v�~���#���f�7��%�>)R>WA���k?���=�fɿ]W%�m+?]�)?�aо�u ?S���/Ŀ����a��ճ)>�b?r���l^���
<���=��(=o��c��������7ѽ��h�w�a���B��(���a=�C���`�`N���<�s�=C�?���Խ��=���������=�
:�?5�Ѐ4�[�-�?I!�1k�l�M��+۽x�p�<ص��sy6�Nj�������(�ݱ���c˿K}�=.o���U�>L��HԨ�������>n��>X0�>d'�vZ�=ݩ>��B���,��,>\z��=V5���k=���������3��$i���9�]>�`	?<�t��鮾:�F����=	9�J�=��,���u�����D����v&���K��^���kU�m�ᾭz��?C+�=����2�>�J��j��A��=�������3�C?�8�>"T�;���=72?O��>8Rx�&X0������l>J�ɿ(h^=������i��-뾂��=�Pƾ^U�=�>�>:&=L��? '��+A?ɳ=�e�>5��� ��_E�;�T=�>�U��?���� �\<nq�=�zl;�c�ƽ|��`~��C"J=~j���={Ͻ��<��ռ��'=���:�2� Q纀�1;�w��Cl�P15�S!��i�
y �a����8�=w-� W�:�bƽ�\j��]���;~�����=2�1���C�pl�<�_������ë<⣾=N���9� �v-�<
�y�%d=&��`�U�=�:(��q<���������&x�=ں"=,��=�伽�O�<�&�g*=�|=�ޞ:��E�l���'�=p<�=c���򬽆='��9=p���"�b�X�_F�󄓽�?���� �^��E>����+>ҽџ!� �W�E��=p9"�7@=:7�=��=�A��i>D���ok:����ݽ2���Ҝν(N��c5ڼۄ��D"��N~��h�<z?f��O�=��ս�$��y��;��(����p�U��G<�X׽v�u�f!�=u�鼲x���k!�˼��s�\�N�G�/qs�1��/�.����˖�7��Ə�r��=��׽@~g��:I��T¼�h����<F��=�,5����.�=7��;�tA��)>PȘ�I�ʽ���<$8c�jC�J=|=�>$�N�c�EC龎4��M?P���=i���$��Ps/?ٜ����u���T��=���>v�����t��<��*�^PN���]#E��ü<m_缄�&���r�CnܿȔ�<δ�>�b�ǨG��2!���n�"٧���=:Ũ�l����?�ʽ�q���紽���?B>�¹���D���;*Y�>]N�?��뾼�?1��
Q�
C?�@=��/���8�o�}?��F?b`���{b>XL�>Q�> $<B�%��b`�ɭ���?$t��pϿO��Pƽ�,�>���쎽-%M�����*������!�7��;�?	�<��Z�����������>��>�g ?�F�>�?�� �ؿ�;�=n�>.3�>���>�j�e��=��g?L��=H�v��ѳ= gm>)��>h�f�_��>O��>�H��>?X����L�������=�@�>�rQ=Y~<٥	>�F���߯=�2\>Hq>q��>;�%�z⎽f>��z�=̢�="ݾ�"�<?��U*=�?�߭>XZd>챁�"��ԙ�Bt����3�<N5���	<����6��S:�<�bྚ�ɾ�A��'��R��=��߾>�<�-����s��՜�b�����ȾA��>~�>4gj?^�Z�!�V�K=]��?P�=J����=�g�=�>w����<�1j��ݽXļ�h	�N@=L����6�=J�>Р\=���=S�<,�<�C���	��o �����E*��)���e�<�R��+�Խ�#(����=�=��5� a0=�d= 	\:��(�����)��(W�̚˽#�8�?�@<qƾ�%x>��=,�4>1D>g���7��>�	b�k9�=��;ڊ>�O;я{>��q?\��s���z>��N�dw��q1a=�5>d<�>Q�����>�������N)���?�=�J���ǾaҼy43���ؿ;}�������>e��M���L�ο��o�J�HB���W�;�q=�q5��Д�&1�=oR�\|���a<=��(�x�u��f��Ϥ�]�#�	�!�Bɏ=H#�=�^��a=�|���X��<X=�=.D�=����������_��[�=���wA;�=����)`�f@	�Rqy=��ǽb�S��y�$���FzV�@� ��Y�;���-_>c�����]��r�<�����:(=���_xH>=��%�f�!�PP|=�G�0�-�B�½wS���=����{�����+8=6�`L��Y�;�Wx<�����������&������J�f��=�k���v��m�={-%�����<�?��?}�>�!1>B��z+����v=F�>ϟ�j׽��{>>'+?�$>���j�7��Q�)J>��*�v�=NB>�����?���<C�2f�=ERӽ߻�=�m>q����=1z�=�O>!�g��B�=��ӽO�R��݄��Z0���W������������?[t���06?_�����׾:6O�-�A@(�޾Hݿ(��<d*6@?��VI��/w?�s3>
��=dr�>��L�@ؔ=�xs�M�>jQ�I�
�F���!�>�Q��P�?��?�C���^��w��KR��$����p����k�j�z>�=��?->bN�
���=��8=;�=�%��b�D�`�rm������Y���޾��ۄ��?��>nn���{�-(}�G��>/��=�>ʤǾ
�M>�'v�X=�vɾ���5��=��>���>K��?�)�����oΧ���h?M�[������&��=L�<|E�=���t�_���]�u��ҽ@^�¥r��[;)3���=��U�0�c=����f�=u�=i�d<�:!��_ֽozȽg��߸�=��n�< �
�+���\��0�=��ս��=K�H�����u4������>�M��>+?�'g��f^��3���q˿l?GC>�!5�>G���
���j��.��7[�������]�:�ɿl�b����	����=����>����ڽ:�	? k�>1a+>����r��?�P ���Ǿ23��1��k��>N��o:���!��m�?a�>o:��N����O�@Td>�ig>>���Ҵ�ဿP.>ꎔ>F{�>��?C>�<�����|=ւ��A��D���vd����^��>�\>�>��]w{��ڽ|�)�eX侙�n���r>�x>>3kN�_�~>+��?����/?��d>/�>zp�����?